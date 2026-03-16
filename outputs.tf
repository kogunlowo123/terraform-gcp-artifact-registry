output "repository_id" {
  description = "The repository ID."
  value       = google_artifact_registry_repository.this.repository_id
}

output "repository_name" {
  description = "The full resource name of the repository."
  value       = google_artifact_registry_repository.this.name
}

output "repository_url" {
  description = "The URI of the repository for docker push/pull."
  value       = "${var.location}-docker.pkg.dev/${var.project_id}/${var.repository_id}"
}

output "create_time" {
  description = "The time when the repository was created."
  value       = google_artifact_registry_repository.this.create_time
}

output "update_time" {
  description = "The time when the repository was last updated."
  value       = google_artifact_registry_repository.this.update_time
}

output "format" {
  description = "The format of the repository."
  value       = google_artifact_registry_repository.this.format
}

output "mode" {
  description = "The mode of the repository."
  value       = google_artifact_registry_repository.this.mode
}

output "effective_labels" {
  description = "The effective labels on the repository."
  value       = google_artifact_registry_repository.this.effective_labels
}
