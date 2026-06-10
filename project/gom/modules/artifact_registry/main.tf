# ==============================================================================
# Moduł Artifact Registry 
# ==============================================================================


resource "google_artifact_registry_repository" "repositories" {
  for_each = var.repositories

  project       = var.gcp_project_id
  location      = "europe-central2"
  repository_id = each.key
  format        = each.value.format
  description   = each.value.description
}
