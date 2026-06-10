output "project_id" {
  value = google_project.project.project_id
}

output "storage_buckets" {
  value = keys(module.project_storage.buckets)
}

output "bigquery_datasets" {
  value = keys(module.project_big_query.datasets)
}

output "iam_member" {
  description = "Mapa przypisanych uprawnień pobrana z podmodułu IAM"
  value = {
    for key, binding in module.project_iam.project_permissions : key => binding.member
  }
}

output "repositories" {
  value = module.project_artifact_registry.repositories
}

output "service_accounts" {
  value = { for k, sa in google_service_account.project_sa : k => sa.email }
}

# NOWY, ZŁOŻONY OUTPUT: Łączy uprawnienia użytkowników i kont serwisowych
output "iam_bindings" {
  description = "Pełna mapa uprawnień (Użytkownicy z modułu IAM + Konta Serwisowe)"
  value = merge(
    # 1. Pobieranie uprawnień użytkowników z podmodułu IAM
    {
      for key, binding in module.project_iam.project_permissions : key => binding.member
    },
    # 2. Pobieranie uprawnień kont serwisowych z lokalnego zasobu w project_factory
    {
      for key, binding in google_project_iam_member.sa_roles : key => binding.member
    }
  )
}
