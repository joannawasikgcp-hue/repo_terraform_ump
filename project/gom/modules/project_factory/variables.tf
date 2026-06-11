# ==============================================================================
# 1. Podstawowe dane projektu GCP
# ==============================================================================
variable "project_name" {
  type        = string
  description = "Pełna nazwa wyświetlana projektu w konsoli Google Cloud (display name)."
}

variable "project_id" {
  type        = string
  description = "Globalnie unikalny identyfikator projektu (ID), który zostanie nadany w GCP."
}

variable "description" {
  type        = string
  description = "Biznesowy opis przeznaczenia projektu, widoczny w metadanych."
}

# ==============================================================================
# 2. Parametry Organizacji i Rozliczeń (GCP Context)
# ==============================================================================
variable "org_id" {
  type        = string
  description = "Cyfrowy identyfikator organizacji GCP, w której powstanie projekt."
}

variable "folder_id" {
  type        = string
  description = "Cyfrowy identyfikator folderu (np. folderu UMP), w którym projekt ma zostać umieszczony."
}

variable "billing_account" {
  type        = string
  description = "Identyfikator konta rozliczeniowego GCP (Billing Account ID), do którego zostanie przypisany projekt."
}

# ==============================================================================
# 3. Usługi API i Funkcje Sterujące
# ==============================================================================
variable "apis_to_enable" {
  type        = list(string)
  description = "Połączona lista bazowych oraz dodatkowych usług API, które fabryka musi włączyć w tym projekcie."
}

#variable "monthly_budget_usd" {
 # type        = number
  #description = "Miesięczny budżet w USD przypisany do tego projektu na potrzeby alertów kosztowych."
#}

variable "enable_gdrive_gcs_sa" {
  type        = bool
  description = "Flaga logiczna (true/false) decydująca o tym, czy w projekcie ma powstać konto serwisowe do integracji z Google Drive."
}

# ==============================================================================
# 4. Struktury danych dla Modułów Zasobowych - Cloud Storage
# ==============================================================================
variable "storage_buckets" {
  # POPRAWIONE: Zmiana z list(object) na list(string), aby pasowało do nowego tfvars
  type        = list(string)
  description = "Lista samych nazw własnych dla bucketów Cloud Storage, które zostaną utworzone w tym projekcie."
}

# ==============================================================================
# 5. Struktury danych dla Modułów Zasobowych - Big Query
# ==============================================================================

variable "bigquery_datasets" {
  type        = list(string)
  description = "Lista samych nazw datasetów BigQuery, które mają zostać utworzone wewnątrz tego projektu."
}

# ==============================================================================
# 6. Struktury danych dla Modułów Zasobowych - IAM
# ==============================================================================

variable "iam_roles" {
  type        = map(list(string))
  description = "Mapa uprawnień IAM dla tego projektu (Klucz: rola, Wartość: lista użytkowników/grup)."
}

# ==============================================================================
# 7. Struktury danych dla Modułów Zasobowych - Artifact Registry
# ==============================================================================

variable "repositories" {
  type = map(object({
    format      = string
    description = string
  }))
}

# ==============================================================================
# 8. Struktury danych dla Modułów Zasobowych - Cloud SQL
# ==============================================================================


variable "cloud_sql" {
  description = "Konfiguracja instancji Cloud SQL (null = brak bazy w projekcie)"
  type = object({
    name             = string
    database_version = optional(string, "POSTGRES_18")
    region           = optional(string, "europe-central2")
    tier             = optional(string, "db-perf-optimized-N-2")
    zone             = optional(string, "europe-central2-a")
    availability_type   = optional(string, "REGIONAL")
    deletion_protection = optional(bool, true)
    disk_type             = optional(string, "PD_SSD")
    disk_size             = optional(number, 10)
    disk_autoresize       = optional(bool, true)
    disk_autoresize_limit = optional(number, 0)
    ipv4_enabled       = optional(bool, false)
    private_network    = optional(string, null)
    allocated_ip_range = optional(string, null)
    external_ip_range  = optional(string, null)
    backup_enabled                 = optional(bool, true)
    backup_start_time              = optional(string, "02:00")
    backup_retained_backups        = optional(number, 30)
    point_in_time_recovery_enabled = optional(bool, true)
    db_name      = string
    db_charset   = optional(string, "UTF8")
    db_collation = optional(string, "en_US.UTF8")
    user_name     = optional(string, "db-admin")
    #user_password = optional(string, null)
  })
  default = null
}
