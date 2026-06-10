
# Ewentualnie do zmiany na:
# variable "cs_config"{
#   description = "Konfiguracja Cloud Storage"
#   type = object(
#   {
#     gcp_project_id = string
#     buckets = string
#   }
# )
# }
# odwołanie w main.tf -> project       = var.cs_config.gcp_project_id
      

variable "gcp_project_id" {
  type        = string
  description = "Identyfikator projektu GCP, w którym mają zostać utworzone buckety."
}

variable "buckets" {
  type        = list(string) 
  description = "Lista samych nazw własnych dla bucketów Cloud Storage, które zostaną utworzone zgodnie z odgórnym standardem firmowym."
}
