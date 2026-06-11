# ==============================================================================
# Moduł Cloud SQL - Definicja Zasobów i Konfiguracji PostgreSQL
# ==============================================================================

module "cloud_sql" {
  source  = "terraform-google-modules/sql-db/google//modules/postgresql"
  version = "~> 28.1"

  # ==============================================================================
  # Podstawowe Parametry Instancji
  # ==============================================================================

  name                 = var.name
  random_instance_name = true
  project_id           = var.gcp_project_id
  database_version     = var.database_version
  region               = var.region

  # ==============================================================================
  # Konfiguracja Głównej Instancji (Master)
  # ==============================================================================

  tier                            = var.tier
  zone                            = var.zone
  availability_type               = var.availability_type
  maintenance_window_day          = var.maintenance_window_day
  maintenance_window_hour         = var.maintenance_window_hour
  maintenance_window_update_track = var.maintenance_window_update_track

  deletion_protection   = var.deletion_protection
  disk_type             = var.disk_type
  disk_size             = var.disk_size
  disk_autoresize       = var.disk_autoresize
  disk_autoresize_limit = var.disk_autoresize_limit

  database_flags = var.database_flags
  user_labels    = var.user_labels

  # ==============================================================================
  # Konfiguracja Sieci
  # ==============================================================================

  ip_configuration = {
    ipv4_enabled       = var.ipv4_enabled
    ssl_mode           = var.ssl_mode
    private_network    = var.private_network
    allocated_ip_range = var.allocated_ip_range
    authorized_networks = var.external_ip_range != null ? [
      {
        name  = "${var.gcp_project_id}-cidr"
        value = var.external_ip_range
      }
    ] : []
  }

  # ==============================================================================
  # Konfiguracja Backupów
  # ==============================================================================

  backup_configuration = {
    enabled                        = var.backup_enabled
    start_time                     = var.backup_start_time
    location                       = null
    point_in_time_recovery_enabled = var.point_in_time_recovery_enabled
    transaction_log_retention_days = null                                # Terraform nie zarządza retencją logów
    retained_backups               = var.backup_retained_backups
    retention_unit                 = "COUNT"                             # Zliczamy backupy (nie czas)
  }

  # ==============================================================================
  # Konfiguracja Read Replik
  # ==============================================================================

  read_replica_name_suffix = var.read_replica_name_suffix
  read_replicas            = var.read_replicas

  # ==============================================================================
  # Konfiguracja Bazy Danych
  # ==============================================================================

  db_name      = var.db_name
  db_charset   = var.db_charset
  db_collation = var.db_collation

  additional_databases = var.additional_databases

  # ==============================================================================
  # Konfiguracja Użytkowników
  # ==============================================================================

  user_name     = var.user_name
  user_password = random_password.db_password.result 

  additional_users = var.additional_users

  # ==============================================================================
  # FIRMOWE STANDARDY BEZPIECZEŃSTWA (Zaszyte w module)
  # ==============================================================================

  # deletion_protection = true    → domyślnie włączone, chroni przed przypadkowym terraform destroy
  # ssl_mode = "ENCRYPTED_ONLY"   → domyślnie tylko szyfrowane połączenia
  # backup_enabled = true         → domyślnie backupy zawsze włączone
  # ipv4_enabled = false          → domyślnie brak publicznego IP, tylko prywatna sieć VPC
}

# ==============================================================================
# Generowanie Hasła i Zarządzanie Sekretami
# ==============================================================================

resource "random_password" "db_password" {
  length  = 24
  special = false
}

resource "google_secret_manager_secret" "db_credentials" {
  project   = var.gcp_project_id
  secret_id = "${var.name}-db-credentials"

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "db_credentials" {
  secret = google_secret_manager_secret.db_credentials.id

  secret_data = jsonencode({
    project_id  = var.gcp_project_id
    instance_id = module.cloud_sql.instance_connection_name
    username    = var.user_name
    password    = random_password.db_password.result
  })

  depends_on = [module.cloud_sql]
}