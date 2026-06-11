# ==============================================================================
# Projekt
# ==============================================================================

output "project_id" {
  description = "ID projektu GCP"
  value       = google_project.project.project_id
}

# ==============================================================================
# Storage
# ==============================================================================

output "storage_buckets" {
  description = "Lista utworzonych bucketów Cloud Storage"
  value       = keys(module.project_storage.buckets)
}

# ==============================================================================
# BigQuery
# ==============================================================================

output "bigquery_datasets" {
  description = "Lista utworzonych datasetów BigQuery"
  value       = keys(module.project_big_query.datasets)
}

# ==============================================================================
# Artifact Registry
# ==============================================================================

output "repositories" {
  description = "Lista utworzonych repozytoriów Artifact Registry"
  value       = module.project_artifact_registry.repositories
}

# ==============================================================================
# Cloud SQL
# ==============================================================================

output "cloud_sql" {
  description = "Informacje o instancji Cloud SQL (null jeśli projekt nie ma bazy)"
  value = { for k, v in module.project_cloud_sql : k => {
    instance_name = v.instance_name
    db_name       = v.db_name
  }}
}

# ==============================================================================
# IAM - Uprawnienia
# ==============================================================================

output "iam_member" {
  description = "Mapa przypisanych uprawnień pobrana z podmodułu IAM"
  value = {
    for key, binding in module.project_iam.project_permissions : key => binding.member
  }
}

output "iam_bindings" {
  description = "Pełna mapa uprawnień (Użytkownicy z modułu IAM + Konta Serwisowe)"
  value = merge(
    {
      for key, binding in module.project_iam.project_permissions : key => binding.member
    },
    {
      for key, binding in google_project_iam_member.sa_roles : key => binding.member
    }
  )
}

# ==============================================================================
# Service Accounts
# ==============================================================================

output "service_accounts" {
  description = "Mapa kont serwisowych i ich adresów email"
  value       = { for k, sa in google_service_account.project_sa : k => sa.email }
}
