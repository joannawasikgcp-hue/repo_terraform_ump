# ==============================================================================
# 1. Outptu to return dla utworzonych zasobów - to oznacza że wyświetlana jest informacja o zasobach utworzonych w ramach terraform
# ==============================================================================

output "created_projects" {
  description = "Podsumowanie utworzonych projektów GCP wraz z zasobami"
  value = {
    for key, project in module.gcp_projects_factory : key => {
      project_id        = project.project_id
      storage_buckets   = project.storage_buckets
      bigquery_datasets = project.bigquery_datasets
      iam_bindings      = project.iam_member
      iam_bindings      = project.iam_bindings
      repositories      = project.repositories
      service_accounts  = project.service_accounts
    }
  }
}
