

# ==============================================================================
# Definicja wymaganego dostawcy
# ==============================================================================

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.22"      #"6.8.0" 
    }
  }
  #required_version = ">= 0.13"
}

# ==============================================================================
# Główny blok dostawcy Google (Inicjalizacja połączenia do GCP)
# ==============================================================================

# Blok dostawcy Google, który użyje zmiennych
provider "google" {
  #project = var.project_id
  project = "admin-project-498213"
  region  = var.region
}

# ==============================================================================
# Pobieranie danych z Secret Managera (Używa połączenia zdefiniowanego wyżej)
# ==============================================================================
data "google_secret_manager_secret_version" "terraform_pmo_projects" {
  secret  = "terraform_pmo_projects"
  project = "803770291613" 
  version = "latest"
}

# ==============================================================================
# Parsowanie tajnych danych do zmiennych lokalnych (Dostępne w całym projekcie)
# ==============================================================================
locals {
  secret_data = jsondecode(data.google_secret_manager_secret_version.terraform_pmo_projects.secret_data)

  # Te trzy zmienne są teraz "globalnie" dostępne w Twoim kodzie jako local.xxx
  billing_account = local.secret_data["billing_account"]
  org_id          = local.secret_data["org_id"]
  folder_id       = local.secret_data["folder_id"]
}