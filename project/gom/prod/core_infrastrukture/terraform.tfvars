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
  "tech-database" = {
    display_name       = "tech-database"
    project_id         = "tech-database-prod"
    description        = "Projekt produkcyjny main dla GCP"
    extra_apis         = []

    enable_gdrive_gcs_sa = true

    # Definicja zasobów
    storage_buckets = ["amazon_daily_prod", "jira_bucket_pull_prod"]
    bigquery_datasets = ["DWH_ODS","DWH_STG", "DWH_TCH", "HC_Analityka"]
    
    iam_roles         = {
      "roles/viewer" = [
        "user:joanna.woloszyn33@gmail.com.pl",
      ],
      }

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
