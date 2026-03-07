locals {
  repository_name = "projects/${var.project_id}/locations/${var.location}/repositories/${var.repository_id}"

  is_docker = var.format == "DOCKER"
  is_maven  = var.format == "MAVEN"

  is_standard = var.mode == "STANDARD_REPOSITORY"
  is_virtual  = var.mode == "VIRTUAL_REPOSITORY"
  is_remote   = var.mode == "REMOTE_REPOSITORY"

  iam_bindings_flat = flatten([
    for role, members in var.iam_bindings : [
      for member in members : {
        role   = role
        member = member
      }
    ]
  ])

  default_labels = {
    managed-by = "terraform"
  }

  merged_labels = merge(local.default_labels, var.labels)
}
