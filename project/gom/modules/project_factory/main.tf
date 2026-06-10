# ==============================================================================
# 1. Tworzenie projektu w chmurze Google Cloud Platform (GCP)
# ==============================================================================

resource "google_project" "project" {
  name            = var.project_name
  project_id      = var.project_id
  folder_id       = var.folder_id
  billing_account = var.billing_account
}

resource "google_project_default_service_accounts" "default_sa" {
  project = google_project.project.project_id
  action  = "DELETE"
}


# ==============================================================================
# 2. Aktywacja podstawowych oraz dodatkowych usług API dla projektu
# ==============================================================================

resource "google_project_service" "services" {
  for_each = toset(var.apis_to_enable)
  project = google_project.project.project_id
  service = each.value
}

# ==============================================================================
# 3. Integracja z dedykowanym modułem zarządzania zasobami Cloud Storage
# ==============================================================================

module "project_storage" {
  source = "../cloud_storage"

  gcp_project_id = google_project.project.project_id
  buckets        = var.storage_buckets

  depends_on = [google_project_service.services]
}

# ==============================================================================
# 4. Integracja z dedykowanym modułem bazodanowym i analitycznym BigQuery
# ==============================================================================
module "project_big_query" {
  source = "../big_query"

  gcp_project_id = google_project.project.project_id
  datasets       = var.bigquery_datasets

  depends_on = [google_project_service.services]
}


# ==============================================================================
# 5. Kreacja kont serwisowych
# ==============================================================================

locals {
  gdrive_account = var.enable_gdrive_gcs_sa ? {
    "cloud-storage-sa" = "Konto Integracji GDrive do Cloud Storage"
  } : {}

  standard_accounts = {
    "cloud-build-sa" = "Konto Serwisowe dedykowane dla Cloud Build"
    "cloud-run-sa"   = "Konto Serwisowe dedykowane dla Cloud Run"
  }

  all_service_accounts = merge(local.gdrive_account, local.standard_accounts)

  sa_roles = {
    "cloud-build-sa" = [
      "roles/artifactregistry.writer",
      "roles/cloudbuild.builds.editor",
      "roles/logging.logWriter",
      "roles/logging.privateLogViewer"
    ]
    "cloud-run-sa" = [
      "roles/bigquery.dataEditor",
      "roles/run.admin",
      "roles/compute.storageAdmin",
      "roles/secretmanager.secretAccessor",
      "roles/bigquery.jobUser"
    ]
  }

  sa_role_bindings = flatten([
    for sa, roles in local.sa_roles : [
      for role in roles : {
        sa   = sa
        role = role
      }
    ]
  ])
}

resource "google_service_account" "project_sa" {
  for_each = local.all_service_accounts

  project      = google_project.project.project_id
  account_id   = each.key
  display_name = each.value
}

# ==============================================================================
# 6. Przypisanie ról IAM do kont serwisowych
# ==============================================================================

resource "google_project_iam_member" "sa_roles" {
  for_each = { for b in local.sa_role_bindings : "${b.sa}/${b.role}" => b }

  project = google_project.project.project_id
  role    = each.value.role
  member  = "serviceAccount:${google_service_account.project_sa[each.value.sa].email}"

  depends_on = [google_service_account.project_sa]
}

# ==============================================================================
# 7. Moduł IAM - Zarządzanie Dostępem i Uprawnieniami użytkowników
# ==============================================================================

module "project_iam" {
  source = "../iam"

  gcp_project_id = google_project.project.project_id
  iam_roles      = var.iam_roles

  depends_on = [google_project.project]
}

# ==============================================================================
# 8. Moduł Artifact Registry - Zarządzanie obrazami docker
# ==============================================================================

module "project_artifact_registry" {
  source = "../artifact_registry"

  gcp_project_id = google_project.project.project_id
  repositories   = var.repositories

  depends_on = [google_project_service.services]
}