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
