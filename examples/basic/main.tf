provider "google" {
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
  repository_id = "my-docker-repo"
  description   = "Docker container image repository"
  format        = "DOCKER"

  labels = {
    environment = "dev"
    team        = "platform"
  }
}

output "repository_url" {
  description = "The Docker repository URL."
  value       = module.docker_repo.repository_url
}

output "repository_name" {
  description = "The repository full name."
  value       = module.docker_repo.repository_name
}
