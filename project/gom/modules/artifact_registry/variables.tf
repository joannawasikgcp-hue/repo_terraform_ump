

variable "gcp_project_id" {
  type        = string
  description = "Identyfikator projektu GCP, w którym zostaną utworzone repozytoria Artifact Registry."
}

variable "repositories" {
  type = map(object({
    format      = string  # DOCKER, PYTHON, NPM, MAVEN
    description = string
  }))
  description = "Mapa repozytoriów Artifact Registry do utworzenia w projekcie."
}
