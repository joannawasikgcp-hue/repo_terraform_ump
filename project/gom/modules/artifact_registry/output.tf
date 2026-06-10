output "repositories" {
  value = keys(google_artifact_registry_repository.repositories)
}
