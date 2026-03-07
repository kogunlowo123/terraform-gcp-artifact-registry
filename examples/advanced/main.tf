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

module "docker_repo" {
  source = "../../"

  project_id    = var.project_id
  location      = var.region
  repository_id = "production-docker"
  description   = "Production Docker repository with cleanup policies and IAM"
  format        = "DOCKER"

  docker_config = {
    immutable_tags = true
  }

  cleanup_policies = [
    {
      id     = "delete-untagged-images"
      action = "DELETE"
      condition = {
        tag_state  = "UNTAGGED"
        older_than = "2592000s" # 30 days
      }
    },
    {
      id     = "delete-old-tagged"
      action = "DELETE"
      condition = {
        tag_state    = "TAGGED"
        tag_prefixes = ["dev-", "test-"]
        older_than   = "7776000s" # 90 days
      }
    },
    {
      id     = "keep-minimum-versions"
      action = "KEEP"
      most_recent_versions = {
        keep_count = 10
      }
    }
  ]

  iam_bindings = {
    "roles/artifactregistry.reader" = [
      "serviceAccount:${var.project_id}@appspot.gserviceaccount.com",
    ]
    "roles/artifactregistry.writer" = [
      "serviceAccount:ci-builder@${var.project_id}.iam.gserviceaccount.com",
    ]
  }

  labels = {
    environment = "production"
    team        = "platform"
    cost-center = "engineering"
  }
}

module "npm_repo" {
  source = "../../"

  project_id    = var.project_id
  location      = var.region
  repository_id = "npm-packages"
  description   = "Private npm package repository"
  format        = "NPM"

  cleanup_policies = [
    {
      id     = "delete-old-snapshots"
      action = "DELETE"
      condition = {
        version_name_prefixes = ["0.0."]
        older_than            = "7776000s"
      }
    }
  ]

  labels = {
    environment = "production"
    team        = "frontend"
  }
}

output "docker_repo_url" {
  description = "Docker repository URL."
  value       = module.docker_repo.repository_url
}

output "npm_repo_name" {
  description = "NPM repository name."
  value       = module.npm_repo.repository_name
}
