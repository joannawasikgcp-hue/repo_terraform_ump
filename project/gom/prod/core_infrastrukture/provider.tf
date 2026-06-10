
# ==============================================================================
# Definicja wymaganego dostawcy
# ==============================================================================

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.8.0"

    }
  }
  #required_version = ">= 0.13"
}

# ==============================================================================
# Główny blok dostawcy Google (Inicjalizacja połączenia do GCP)
# ==============================================================================

provider "google" {
  #project = var.project_id
  project = "admin-project"
  region  = var.region
}

# ==============================================================================
# Pobieranie danych z Secret Managera (Używa połączenia zdefiniowanego wyżej)
# ==============================================================================
data "google_secret_manager_secret_version" "core_infra_secrets" {
  secret  = "terraform_core_infrastructure"
  project = "803770291613" # ID projektu numeryczne (zgodnie z Twoją ścieżką)
  version = "latest"
}

# ==============================================================================
# Parsowanie tajnych danych do zmiennych lokalnych (Dostępne w całym projekcie)
# ==============================================================================
locals {
  secret_data = jsondecode(data.google_secret_manager_secret_version.core_infra_secrets.secret_data)

  # Te trzy zmienne są teraz "globalnie" dostępne w Twoim kodzie jako local.xxx
  billing_account = local.secret_data["billing_account"]
  org_id          = local.secret_data["org_id"]
  folder_id       = local.secret_data["folder_id"]
}