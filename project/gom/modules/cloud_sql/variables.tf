# ==============================================================================
# Moduł Cloud SQL - Definicja Zasobów i Konfiguracji PostgreSQL
# ==============================================================================

# ==============================================================================
# Podstawowe Parametry Instancji
# ==============================================================================

variable "name" {
  description = "Nazwa instancji Cloud SQL"
  type        = string
}

variable "gcp_project_id" {
  description = "Identyfikator projektu GCP"
  type        = string
}

variable "database_version" {
  description = "Wersja bazy danych"
  type        = string
  default     = "POSTGRES_18"
}

variable "region" {
  description = "Region GCP dla instancji Cloud SQL"
  type        = string
  default     = "europe-central2"
}

# ==============================================================================
# Konfiguracja Głównej Instancji (Master)
# ==============================================================================

variable "tier" {
  description = "Typ maszyny dla instancji"
  type        = string
  default     = "db-perf-optimized-N-2"
}

variable "zone" {
  description = "Strefa GCP dla głównej instancji"
  type        = string
  default     = "europe-central2-a"
}

variable "availability_type" {
  description = "Typ dostępności: REGIONAL (HA) lub ZONAL"
  type        = string
  default     = "REGIONAL"
}

variable "maintenance_window_day" {
  description = "Dzień okna maintenance (1=Pon, 7=Nd)"
  type        = number
  default     = 7
}

variable "maintenance_window_hour" {
  description = "Godzina okna maintenance (UTC)"
  type        = number
  default     = 12
}

variable "maintenance_window_update_track" {
  description = "Ścieżka aktualizacji: stable lub canary"
  type        = string
  default     = "stable"
}

variable "deletion_protection" {
  description = "Ochrona przed usunięciem instancji"
  type        = bool
  default     = true
}

variable "disk_type" {
  description = "Typ dysku: PD_SSD lub PD_HDD"
  type        = string
  default     = "PD_SSD"
}

variable "disk_size" {
  description = "Rozmiar dysku w GB"
  type        = number
  default     = 10
}

variable "disk_autoresize" {
  description = "Czy dysk ma się automatycznie powiększać"
  type        = bool
  default     = true
}

variable "disk_autoresize_limit" {
  description = "Maksymalny rozmiar dysku przy autoresize w GB (0 = brak limitu)"
  type        = number
  default     = 0
}

variable "database_flags" {
  description = "Flagi konfiguracyjne bazy danych"
  type        = list(object({ name = string, value = string }))
  default     = []
}

variable "user_labels" {
  description = "Labele przypisane do instancji"
  type        = map(string)
  default     = {}
}

# ==============================================================================
# Konfiguracja Sieci
# ==============================================================================

variable "ipv4_enabled" {
  description = "Czy włączyć publiczny adres IPv4"
  type        = bool
  default     = false
}

variable "ssl_mode" {
  description = "Tryb SSL: ENCRYPTED_ONLY lub ALLOW_UNENCRYPTED_AND_ENCRYPTED"
  type        = string
  default     = "ENCRYPTED_ONLY"
}

variable "private_network" {
  description = "Self-link do VPC dla prywatnego IP"
  type        = string
  default     = null
}

variable "allocated_ip_range" {
  description = "Nazwa zarezerwowanego zakresu IP dla prywatnego połączenia"
  type        = string
  default     = null
}

variable "external_ip_range" {
  description = "Zewnętrzny zakres IP dozwolony do połączeń (CIDR)"
  type        = string
  default     = null
}

# ==============================================================================
# Konfiguracja Backupów
# ==============================================================================

variable "backup_enabled" {
  description = "Czy włączyć backupy"
  type        = bool
  default     = true
}

variable "backup_start_time" {
  description = "Godzina rozpoczęcia backupu (HH:MM)"
  type        = string
  default     = "02:00"
}

variable "backup_retained_backups" {
  description = "Liczba przechowywanych backupów"
  type        = number
  default     = 30
}

variable "point_in_time_recovery_enabled" {
  description = "Czy włączyć Point-in-Time Recovery"
  type        = bool
  default     = true
}

# ==============================================================================
# Konfiguracja Read Replik -  kopia głównej bazy danych (read-only)
# ==============================================================================

variable "read_replica_name_suffix" {
  description = "Suffix nazwy dla read replik"
  type        = string
  default     = "-replica"
}

variable "read_replicas" {
  description = "Konfiguracja read replik"
  type = list(object({
    name              = string
    zone              = string
    availability_type = string
    tier              = string
    disk_type         = string
    disk_autoresize   = bool
    disk_size         = number
    user_labels       = map(string)
    database_flags    = list(object({ name = string, value = string }))
    ip_configuration  = any
  }))
  default = []
}

# ==============================================================================
# Konfiguracja Bazy Danych
# ==============================================================================

variable "db_name" {
  description = "Nazwa domyślnej bazy danych"
  type        = string
}

variable "db_charset" {
  description = "Charset bazy danych - character set = UTF8 Zażółć gęślą jaźń"
  type        = string
  default     = "UTF8"
}

variable "db_collation" {
  description = "Collation bazy danych - sposób sortowania danych z polskimi znakami Ł w środku nie na końcu"
  type        = string
  default     = "en_US.UTF8"
}

variable "additional_databases" {
  description = "Lista dodatkowych baz danych"
  type = list(object({
    name      = string
    charset   = string
    collation = string
  }))
  default = []
}

# ==============================================================================
# Konfiguracja Użytkowników
# ==============================================================================

variable "user_name" {
  description = "Nazwa głównego użytkownika bazy"
  type        = string
  #default     = "db-admin"
}

variable "additional_users" {
  description = "Lista dodatkowych użytkowników bazy"
  #sensitive   = true
  type = list(object({
    name            = string
    password        = string
    host            = string
    random_password = bool
  }))
  default = []
}
