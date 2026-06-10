# ==============================================================================
# W tej sekcji umieszczamy dane produkcyjne, takie jak nazwy projektów, ID itp.
# Wartości te automatycznie uzupełniają zmienne zadeklarowane w variables.tf,
# z których następnie korzysta kod w pliku main.tf.
# ==============================================================================


# ==============================================================================
# Globalne ustawienia dla folderu UMP
# ==============================================================================
# org_id          = ""
# folder_id       = ""
# billing_account = ""
# region          = ""

# ==============================================================================
# Wspólna lista API dla każdego projektu
# ==============================================================================
base_apis = [

    # --- Dane i analityka ---

  "storage.googleapis.com",
  "bigquery.googleapis.com",
  "bigquerystorage.googleapis.com",
  "bigqueryconnection.googleapis.com",
  "dataplex.googleapis.com",
  "datalineage.googleapis.com",

  # --- Integracje Google Workspace ---

  "drive.googleapis.com",
  "sheets.googleapis.com",

  # --- AI i ML ---

  "aiplatform.googleapis.com",
  "discoveryengine.googleapis.com",
  "notebooks.googleapis.com",

  # --- Messaging i eventy ---

  "pubsub.googleapis.com",

  # --- CI/CD i deployment ---

  "cloudbuild.googleapis.com",
  "artifactregistry.googleapis.com",
  "cloudfunctions.googleapis.com",
  "run.googleapis.com",

  # --- Bezpieczeństwo i IAM ---

  "iam.googleapis.com",
  "secretmanager.googleapis.com",
  "policyanalyzer.googleapis.com",
  "cloudresourcemanager.googleapis.com",
  
  # --- Observability ---

  "logging.googleapis.com",
  "monitoring.googleapis.com",
  
]

# ==============================================================================
# Definicja projektów
# ==============================================================================

# ==============================================================================
# Definicja projektów - ValueMedia
# ==============================================================================

gcp_projects = {
  "valuemedia" = {
    display_name       = "ValueMedia"
    project_id         = "ump-valuemedia-prod"
    description        = "Projekt dla spółki ValueMedia obsługujący hurtownię danych Cloud Storage oraz BigQuery. Przeznaczony do projektu AI."
    extra_apis         = []

    enable_gdrive_gcs_sa = true

    # Definicja zasobów
    storage_buckets = ["value_media_tui", "value_media_benefit_systems", "value_media_uniqa"]
    bigquery_datasets = ["tui","benefit_systems", "media_uniqa"]
    iam_roles         = {}
    repositories = {
      "basic-images" = {
        format      = "DOCKER"
        description = "Repozytorium obrazów bazowych wykorzystywanych jako podstawa do budowania obrazów aplikacji."
      },
      "cloud-run-images" = {
        format      = "DOCKER"
        description = "Repozytorium obrazów Docker uruchamianych w środowisku Cloud Run."
      }
    }
  },

  "salestube" = {
    display_name       = "SalesTube"
    project_id         = "ump-salestube-prod"
    description        = "Projekt dla spółki Salestube obsługujący hurtownię danych Cloud Storage oraz BigQuery. Przeznaczony do projektu AI."
    extra_apis         = []

    enable_gdrive_gcs_sa = true

    # Definicja zasobów
    storage_buckets = ["salestube_travelist", "salestubea_lancerto", "salestube_reserved", "salestube_olx", "salestube_prochnik","salestube_phlov"]
    bigquery_datasets = ["travelist","lancertoa","reserved", "olx","phlov"]
    iam_roles         = {}
    repositories = {
      "basic-images" = {
        format      = "DOCKER"
        description = "Repozytorium obrazów bazowych wykorzystywanych jako podstawa do budowania obrazów aplikacji."
      },
      "cloud-run-images" = {
        format      = "DOCKER"
        description = "Repozytorium obrazów Docker uruchamianych w środowisku Cloud Run."
      }
    }
  },






}
