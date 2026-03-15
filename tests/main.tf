module "test" {
  source = "../"

  project_id    = "test-project-id"
  location      = "us-central1"
  repository_id = "test-docker-repo"
  description   = "Test Artifact Registry repository"
  format        = "DOCKER"
  mode          = "STANDARD_REPOSITORY"

  labels = {
    environment = "test"
    managed_by  = "terraform"
  }

  docker_config = {
    immutable_tags = true
  }

  cleanup_policies = [
    {
      id     = "delete-old-images"
      action = "DELETE"
      condition = {
        tag_state  = "UNTAGGED"
        older_than = "2592000s"
      }
    }
  ]

  iam_bindings = {
    "roles/artifactregistry.reader" = [
      "serviceAccount:ci-reader@test-project-id.iam.gserviceaccount.com"
    ]
  }
}
