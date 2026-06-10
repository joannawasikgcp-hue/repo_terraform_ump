variable "gcp_project_id" {
  type        = string
  description = "Identyfikator projektu GCP..."
}

variable "datasets" {
  type        = list(string) 
  description = "Lista nazw datasetów BigQuery przekazywana z poziomu fabryki."
}
