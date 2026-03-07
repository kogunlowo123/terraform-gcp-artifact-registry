provider "google" {
  project = var.project_id
  region  = var.region
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {
  description = "The GCP project ID."
  type        = string
}

variable "region" {
  description = "The GCP region."
  type        = string
  default     = "us-central1"
}

variable "kms_key_name" {
  description = "Cloud KMS key for CMEK encryption."
  type        = string
  default     = null
}

# Standard Docker repository with full configuration
module "docker_standard" {
  source = "../../"

  project_id    = var.project_id
  location      = var.region
  repository_id = "docker-standard"
  description   = "Standard Docker repository with CMEK and cleanup"
  format        = "DOCKER"
  mode          = "STANDARD_REPOSITORY"
  kms_key_name  = var.kms_key_name

  docker_config = {
    immutable_tags = true
  }

  cleanup_policy_dry_run = false

  cleanup_policies = [
    {
      id     = "delete-untagged"
      action = "DELETE"
      condition = {
        tag_state  = "UNTAGGED"
        older_than = "2592000s"
      }
    },
    {
      id     = "delete-stale-dev"
      action = "DELETE"
      condition = {
        tag_state    = "TAGGED"
        tag_prefixes = ["dev-", "test-", "pr-"]
        older_than   = "5184000s" # 60 days
      }
    },
    {
      id     = "keep-latest"
      action = "KEEP"
      most_recent_versions = {
        keep_count = 15
      }
    }
  ]

  iam_bindings = {
    "roles/artifactregistry.reader" = [
      "serviceAccount:${var.project_id}@appspot.gserviceaccount.com",
      "group:developers@example.com",
    ]
    "roles/artifactregistry.writer" = [
      "serviceAccount:ci-builder@${var.project_id}.iam.gserviceaccount.com",
    ]
    "roles/artifactregistry.repoAdmin" = [
      "group:platform-admins@example.com",
    ]
  }

  labels = {
    environment = "production"
    team        = "platform"
    cost-center = "infrastructure"
  }
}

# Remote Docker repository (Docker Hub proxy)
module "docker_remote" {
  source = "../../"

  project_id    = var.project_id
  location      = var.region
  repository_id = "docker-hub-proxy"
  description   = "Remote repository proxying Docker Hub"
  format        = "DOCKER"
  mode          = "REMOTE_REPOSITORY"

  remote_repository_config = {
    description   = "Docker Hub remote proxy"
    upstream_type = "DOCKER_HUB"
  }

  labels = {
    environment = "production"
    type        = "remote-proxy"
  }
}

# Virtual Docker repository aggregating standard and remote
module "docker_virtual" {
  source = "../../"

  project_id    = var.project_id
  location      = var.region
  repository_id = "docker-virtual"
  description   = "Virtual repository aggregating standard and remote repos"
  format        = "DOCKER"
  mode          = "VIRTUAL_REPOSITORY"

  virtual_repository_config = [
    {
      id         = "standard-upstream"
      repository = module.docker_standard.repository_name
      priority   = 10
    },
    {
      id         = "remote-upstream"
      repository = module.docker_remote.repository_name
      priority   = 20
    }
  ]

  labels = {
    environment = "production"
    type        = "virtual"
  }
}

# Maven repository
module "maven_repo" {
  source = "../../"

  project_id    = var.project_id
  location      = var.region
  repository_id = "maven-releases"
  description   = "Maven release repository"
  format        = "MAVEN"

  maven_config = {
    allow_snapshot_overwrites = false
    version_policy            = "RELEASE"
  }

  iam_bindings = {
    "roles/artifactregistry.reader" = [
      "group:developers@example.com",
    ]
    "roles/artifactregistry.writer" = [
      "serviceAccount:ci-builder@${var.project_id}.iam.gserviceaccount.com",
    ]
  }

  labels = {
    environment = "production"
    team        = "backend"
  }
}

# Python repository with remote proxy
module "python_remote" {
  source = "../../"

  project_id    = var.project_id
  location      = var.region
  repository_id = "pypi-proxy"
  description   = "Remote repository proxying PyPI"
  format        = "PYTHON"
  mode          = "REMOTE_REPOSITORY"

  remote_repository_config = {
    description   = "PyPI remote proxy"
    upstream_type = "PYPI"
  }

  labels = {
    environment = "production"
    type        = "remote-proxy"
  }
}

output "standard_docker_url" {
  description = "Standard Docker repository URL."
  value       = module.docker_standard.repository_url
}

output "virtual_docker_url" {
  description = "Virtual Docker repository URL."
  value       = module.docker_virtual.repository_url
}

output "remote_docker_name" {
  description = "Remote Docker repository name."
  value       = module.docker_remote.repository_name
}

output "maven_repo_name" {
  description = "Maven repository name."
  value       = module.maven_repo.repository_name
}

output "python_remote_name" {
  description = "Python remote repository name."
  value       = module.python_remote.repository_name
}
