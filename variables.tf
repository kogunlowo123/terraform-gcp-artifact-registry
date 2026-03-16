variable "project_id" {
  description = "The GCP project ID where the Artifact Registry repository will be created."
  type        = string

  validation {
    condition     = length(var.project_id) > 0
    error_message = "Project ID must not be empty."
  }
}

variable "location" {
  description = "The location (region) for the Artifact Registry repository."
  type        = string
  default     = "us-central1"

  validation {
    condition     = length(var.location) > 0
    error_message = "Location must not be empty."
  }
}

variable "repository_id" {
  description = "The repository ID, must be unique within the project and location."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{0,62}$", var.repository_id))
    error_message = "Repository ID must start with a lowercase letter, contain only lowercase letters, numbers, and hyphens, and be at most 63 characters."
  }
}

variable "description" {
  description = "Description of the repository."
  type        = string
  default     = ""
}

variable "format" {
  description = "The format of packages stored in the repository (DOCKER, MAVEN, NPM, PYTHON, APT, YUM, KUBEFLOW, GO, GENERIC)."
  type        = string
  default     = "DOCKER"

  validation {
    condition     = contains(["DOCKER", "MAVEN", "NPM", "PYTHON", "APT", "YUM", "KUBEFLOW", "GO", "GENERIC"], var.format)
    error_message = "Format must be one of: DOCKER, MAVEN, NPM, PYTHON, APT, YUM, KUBEFLOW, GO, GENERIC."
  }
}

variable "mode" {
  description = "The mode of the repository (STANDARD_REPOSITORY, VIRTUAL_REPOSITORY, REMOTE_REPOSITORY)."
  type        = string
  default     = "STANDARD_REPOSITORY"

  validation {
    condition     = contains(["STANDARD_REPOSITORY", "VIRTUAL_REPOSITORY", "REMOTE_REPOSITORY"], var.mode)
    error_message = "Mode must be one of: STANDARD_REPOSITORY, VIRTUAL_REPOSITORY, REMOTE_REPOSITORY."
  }
}

variable "kms_key_name" {
  description = "Cloud KMS key name for customer-managed encryption, or null for Google-managed keys."
  type        = string
  default     = null
}

variable "labels" {
  description = "Labels to apply to the repository."
  type        = map(string)
  default     = {}
}

variable "cleanup_policy_dry_run" {
  description = "If true, cleanup policies will only log what would be deleted without actually deleting."
  type        = bool
  default     = false
}

variable "cleanup_policies" {
  description = "List of cleanup policies for the repository."
  type = list(object({
    id     = string
    action = optional(string, "DELETE")
    condition = optional(object({
      tag_state             = optional(string)
      tag_prefixes          = optional(list(string))
      version_name_prefixes = optional(list(string))
      package_name_prefixes = optional(list(string))
      older_than            = optional(string)
      newer_than            = optional(string)
    }))
    most_recent_versions = optional(object({
      package_name_prefixes = optional(list(string))
      keep_count            = optional(number)
    }))
  }))
  default = []
}

variable "docker_config" {
  description = "Docker-specific repository configuration with immutable_tags option."
  type = object({
    immutable_tags = optional(bool, false)
  })
  default = null
}

variable "maven_config" {
  description = "Maven-specific repository configuration."
  type = object({
    allow_snapshot_overwrites = optional(bool, false)
    version_policy            = optional(string, "VERSION_POLICY_UNSPECIFIED")
  })
  default = null
}

variable "virtual_repository_config" {
  description = "List of upstream policies for virtual repositories."
  type = list(object({
    id         = string
    repository = string
    priority   = number
  }))
  default = []
}

variable "remote_repository_config" {
  description = "Configuration for remote repositories including upstream type and URI."
  type = object({
    description                 = optional(string, "")
    upstream_type               = optional(string)
    custom_uri                  = optional(string)
    disable_upstream_validation = optional(bool, false)
  })
  default = null
}

variable "iam_bindings" {
  description = "IAM bindings for the repository as a map of role to list of members."
  type        = map(list(string))
  default     = {}
}

variable "vpc_sc_policy" {
  description = "VPC Service Controls access policy name for the repository."
  type        = string
  default     = null
}
