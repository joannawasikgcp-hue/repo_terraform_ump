variable "gcp_project_id" {
  type        = string
  description = "Identyfikator projektu GCP, do którego zostaną przypisane uprawnienia."
}

variable "iam_roles" {
  type        = map(list(string))
  description = "Mapa ról i przypisanych do nich członków (użytkowników, grup, kont serwisowych)."
}
