#output "iam_bindings" {
#  value = {
#    for role, binding in google_project_iam_member.project_permissions : role => binding.members
#  }
#}




output "project_permissions" {
  description = "Surowe dane o uprawnieniach z modułu IAM"
  value       = google_project_iam_member.project_permissions
}