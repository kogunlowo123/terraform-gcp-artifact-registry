resource "google_artifact_registry_repository" "this" {
  provider = google-beta

  project       = var.project_id
  location      = var.location
  repository_id = var.repository_id
  description   = var.description
  format        = var.format
  mode          = var.mode
  kms_key_name  = var.kms_key_name
  labels        = local.merged_labels

  cleanup_policy_dry_run = var.cleanup_policy_dry_run

  dynamic "cleanup_policies" {
    for_each = var.cleanup_policies
    content {
      id     = cleanup_policies.value.id
      action = cleanup_policies.value.action

      dynamic "condition" {
        for_each = cleanup_policies.value.condition != null ? [cleanup_policies.value.condition] : []
        content {
          tag_state             = condition.value.tag_state
          tag_prefixes          = condition.value.tag_prefixes
          version_name_prefixes = condition.value.version_name_prefixes
          package_name_prefixes = condition.value.package_name_prefixes
          older_than            = condition.value.older_than
          newer_than            = condition.value.newer_than
        }
      }

      dynamic "most_recent_versions" {
        for_each = cleanup_policies.value.most_recent_versions != null ? [cleanup_policies.value.most_recent_versions] : []
        content {
          package_name_prefixes = most_recent_versions.value.package_name_prefixes
          keep_count            = most_recent_versions.value.keep_count
        }
      }
    }
  }

  dynamic "docker_config" {
    for_each = local.is_docker && var.docker_config != null ? [var.docker_config] : []
    content {
      immutable_tags = docker_config.value.immutable_tags
    }
  }

  dynamic "maven_config" {
    for_each = local.is_maven && var.maven_config != null ? [var.maven_config] : []
    content {
      allow_snapshot_overwrites = maven_config.value.allow_snapshot_overwrites
      version_policy            = maven_config.value.version_policy
    }
  }

  dynamic "virtual_repository_config" {
    for_each = local.is_virtual ? [1] : []
    content {
      dynamic "upstream_policies" {
        for_each = var.virtual_repository_config
        content {
          id         = upstream_policies.value.id
          repository = upstream_policies.value.repository
          priority   = upstream_policies.value.priority
        }
      }
    }
  }

  dynamic "remote_repository_config" {
    for_each = local.is_remote && var.remote_repository_config != null ? [var.remote_repository_config] : []
    content {
      description                 = remote_repository_config.value.description
      disable_upstream_validation = remote_repository_config.value.disable_upstream_validation

      dynamic "docker_repository" {
        for_each = local.is_docker && remote_repository_config.value.upstream_type == "DOCKER_HUB" ? [1] : []
        content {
          public_repository = "DOCKER_HUB"
        }
      }

      dynamic "docker_repository" {
        for_each = local.is_docker && remote_repository_config.value.upstream_type == "CUSTOM" ? [1] : []
        content {
          custom_repository {
            uri = remote_repository_config.value.custom_uri
          }
        }
      }

      dynamic "maven_repository" {
        for_each = local.is_maven && remote_repository_config.value.upstream_type == "MAVEN_CENTRAL" ? [1] : []
        content {
          public_repository = "MAVEN_CENTRAL"
        }
      }

      dynamic "npm_repository" {
        for_each = var.format == "NPM" && remote_repository_config.value.upstream_type == "NPMJS" ? [1] : []
        content {
          public_repository = "NPMJS"
        }
      }

      dynamic "python_repository" {
        for_each = var.format == "PYTHON" && remote_repository_config.value.upstream_type == "PYPI" ? [1] : []
        content {
          public_repository = "PYPI"
        }
      }
    }
  }
}

resource "google_artifact_registry_repository_iam_member" "bindings" {
  for_each = {
    for binding in local.iam_bindings_flat :
    "${binding.role}-${binding.member}" => binding
  }

  project    = var.project_id
  location   = var.location
  repository = google_artifact_registry_repository.this.name
  role       = each.value.role
  member     = each.value.member
}
