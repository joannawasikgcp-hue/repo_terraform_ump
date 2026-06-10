# ==============================================================================
# Moduł IAM - Zarządzanie Dostępem i Uprawnieniami w Projekcie
# ==============================================================================

locals {
  role_members = flatten([
    for role, members in var.iam_roles : [
      for member in members : {
        role   = role
        member = member
      }
    ]
  ])
}

resource "google_project_iam_member" "project_permissions" {
  for_each = { for rm in local.role_members : "${rm.role}/${rm.member}" => rm }

  project = var.gcp_project_id
  role    = each.value.role
  member  = each.value.member
}

