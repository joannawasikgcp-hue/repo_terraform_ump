# ==============================================================================
# Moduł Cloud SQL - Outputs
# ==============================================================================

# ==============================================================================
# Podstawowe Informacje o Instancji
# ==============================================================================

output "instance_name" {
  description = "Nazwa instancji Cloud SQL"
  value       = module.cloud_sql.instance_name
}

output "db_name" {
  description = "Nazwa domyślnej bazy danych"
  value       = var.db_name
}

output "instance_connection_name" {
  description = "Connection name do użycia przez Cloud SQL Proxy (projekt:region:instancja)"
  value       = module.cloud_sql.instance_connection_name
}

output "db_credentials_secret_id" {
  description = "Ścieżka do credentials bazy danych w Secret Manager"
  value       = google_secret_manager_secret.db_credentials.id
}
