# ==============================================================================
# Moduł BigQuery - Definicja Zasobów i Standardów Analitycznych
# ==============================================================================

resource "google_bigquery_dataset" "datasets" {
  # Przekształcamy listę obiektów w mapę, używając unikalnego dataset_id jako klucza
  # for_each = { for ds in var.datasets : ds.dataset_id => ds }
  for_each = toset(var.datasets)

  project     = var.gcp_project_id
  dataset_id  = each.value    #.dataset_id
  description = "Dataset dla klienta: ${each.value}"
  location    = "EUROPE-CENTRAL2"                                                     

  # FIRMOWE STANDARDY BEZPIECZEŃSTWA (Zaszyte w module):
  
  delete_contents_on_destroy = false                               # Zapobiega usunięciu datasetu za pomocą Terraform, jeśli znajdują się w nim tabele z danymi
  default_table_expiration_ms = null                               # Domyślny czas życia tabel (0 oznacza, że dane nigdy automatycznie nie wygasają/nie znikają)
  storage_billing_model = "LOGICAL"                                # Optymalny model rozliczeń dla zapytań analitycznych BI

  labels = {
    managed-by = "terraform"
    env        = "production"
  }
}
