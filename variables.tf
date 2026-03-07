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
  description = "The repository ID. Must be unique within the project and location."
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
  description = "The format of packages stored in the repository. Supported values: DOCKER, MAVEN, NPM, PYTHON, APT, YUM, KUBEFLOW, GO, GENERIC."
  type        = string
  default     = "DOCKER"

  validation {
    condition     = contains(["DOCKER", "MAVEN", "NPM", "PYTHON", "APT", "YUM", "KUBEFLOW", "GO", "GENERIC"], var.format)
    error_message = "Format must be one of: DOCKER, MAVEN, NPM, PYTHON, APT, YUM, KUBEFLOW, GO, GENERIC."
  }
}

variable "mode" {
  description = "The mode of the repository. Supported values: STANDARD_REPOSITORY, VIRTUAL_REPOSITORY, REMOTE_REPOSITORY."
  type        = string
  default     = "STANDARD_REPOSITORY"

  validation {
    condition     = contains(["STANDARD_REPOSITORY", "VIRTUAL_REPOSITORY", "REMOTE_REPOSITORY"], var.mode)
    error_message = "Mode must be one of: STANDARD_REPOSITORY, VIRTUAL_REPOSITORY, REMOTE_REPOSITORY."
  }
}

variable "kms_key_name" {
  description = "The Cloud KMS resource name of the customer-managed encryption key for repository encryption. If not set, Google-managed keys are used."
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
  description = <<-EOT
    List of cleanup policies for the repository. Each policy is a map with:
    - id: Unique identifier for the policy.
    - action: DELETE or KEEP.
    - condition: (Optional) Condition block with tag_state, tag_prefixes, version_name_prefixes, package_name_prefixes, older_than, newer_than.
    - most_recent_versions: (Optional) Block with package_name_prefixes and keep_count.
  EOT
  type = list(object({
    id     = string
    action = optional(string, "DELETE")
    condition = optional(object({
      tag_state            = optional(string)
      tag_prefixes         = optional(list(string))
      version_name_prefixes = optional(list(string))
      package_name_prefixes = optional(list(string))
      older_than           = optional(string)
      newer_than           = optional(string)
    }))
    most_recent_versions = optional(object({
      package_name_prefixes = optional(list(string))
      keep_count            = optional(number)
    }))
  }))
  default = []
}

variable "docker_config" {
  description = "Docker-specific repository configuration. immutable_tags enables tag immutability."
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
  description = <<-EOT
    Configuration for virtual repositories. List of upstream policies:
    - id: Unique identifier for the upstream policy.
    - repository: Full resource name of the upstream repository.
    - priority: Priority of the upstream repository (lower = higher priority).
  EOT
  type = list(object({
    id         = string
    repository = string
    priority   = number
  }))
  default = []
}

variable "remote_repository_config" {
  description = <<-EOT
    Configuration for remote repositories:
    - description: Description of the remote source.
    - upstream_type: Type of upstream. One of: DOCKER_HUB, MAVEN_CENTRAL, NPMJS, PYPI, CUSTOM.
    - custom_uri: URI for CUSTOM upstream_type.
    - disable_upstream_validation: Whether to disable upstream validation.
  EOT
  type = object({
    description                = optional(string, "")
    upstream_type              = optional(string)
    custom_uri                 = optional(string)
    disable_upstream_validation = optional(bool, false)
  })
  default = null
}

variable "iam_bindings" {
  description = <<-EOT
    IAM bindings for the repository. Map of role => list of members.
    Example: { "roles/artifactregistry.reader" = ["user:dev@example.com"] }
  EOT
  type    = map(list(string))
  default = {}
}

variable "vpc_sc_policy" {
  description = "VPC Service Controls access policy name for the repository. Set to restrict access."
  type        = string
  default     = null
}
