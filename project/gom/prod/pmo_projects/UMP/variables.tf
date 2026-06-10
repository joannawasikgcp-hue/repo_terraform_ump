# ==============================================================================
# Globalne ustawienia dla organizacji i folderu UMP
# ==============================================================================

#variable "org_id" {
#  type        = string
#  description = "Unikalny cyfrowy identyfikator organizacji Google Cloud Platform (np. 1234567890), wewnątrz której będą tworzone zasoby."
#  default = "123456789"       # można zdefiniować jeśłi chcemy defaultową wartość
#}

#variable "folder_id" {
#  type        = string
#  description = "Identyfikator folderu UMP (cyfrowy ID), w którym bezpośrednio zostaną powołane do życia projekty ValueMedia oraz SalesTube."
#}

#variable "billing_account" {
#  type        = string
#  description = "Identyfikator konta rozliczeniowego GCP (Billing Account ID) w formacie XXXXXX-XXXXXX-XXXXXX, do którego zostaną podpięte projekty w celu pokrywania kosztów ich zużycia."
#}

#variable "project_id" { 
#  type = string
#  description = "Id projektu"
#}

variable "region" { 
  type = string
  description = "Region projektu"
  default     = "europe-central2"
}


# ==============================================================================
# Konfiguracja API 
# ==============================================================================

variable "base_apis" {
  type        = list(string)
  description = "Lista podstawowych, wspólnych usług API systemu Google Cloud (np. storage.googleapis.com, bigquery.googleapis.com), które muszą zostać automatycznie włączone w każdym nowo tworzonym projekcie."
}

# ==============================================================================
# Definicje projektów GCP
# ==============================================================================

variable "gcp_projects" {
  type = map(object({
    display_name       = string       # Pełna, czytelna nazwa projektu wyświetlana w konsoli GCP
    project_id         = string       # Globalnie unikalny, techniczny identyfikator projektu w GCP
    description        = string       # Biznesowy opis przeznaczenia projektu lub informacja o właścicielu zasobu
    extra_apis         = list(string) # Lista dodatkowych usług API specyficznych tylko dla tego konkretnego projektu
    enable_gdrive_gcs_sa = bool       # Flaga logiczna (true/false) decydująca o automatycznym utworzeniu konta serwisowego do migracji danych z Google Drive do Cloud Storage
    # monthly_budget_usd = number       # Maksymalny miesięczny budżet projektu w USD, po którego przekroczeniu zostaną wysłane alerty


    storage_buckets = list(string)    # Lista nazw bucketów w ramach projektu GCP
    bigquery_datasets = list(string)  # Lista nazw datasetów w ramach projektu GCP

    # Mapowanie ról IAM na listę użytkowników, grup lub kont serwisowych w projekcie
    iam_roles = map(list(string)) # Klucz: nazwa roli (np. roles/bigquery.admin), Wartość: lista członków (np. user:xyz@domena.pl)

    repositories = map(object({
      format      = string
      description = string
    }))
  }))
  description = "Kompleksowa mapa obiektów definiująca pełną specyfikację techniczną i biznesową dla każdego projektu GCP, w tym infrastrukturę Cloud Storage, BigQuery oraz polityki uprawnień i kontroli kosztów."
}
