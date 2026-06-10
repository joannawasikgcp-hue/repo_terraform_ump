# ==============================================================================
# Wywołanie Fabryki Projektów dla struktur UMP
# ==============================================================================

module "gcp_projects_factory" {
  source   = "../../modules/project_factory"
  for_each = var.gcp_projects

  # Podstawowe dane projektów przekazywane w pętli
  project_name         = each.value.display_name
  project_id           = each.value.project_id
  description          = each.value.description
  enable_gdrive_gcs_sa = each.value.enable_gdrive_gcs_sa
  
  # Łączenie bazowej listy API z opcjonalnymi API specyficznymi dla spółki
  apis_to_enable       = concat(var.base_apis, each.value.extra_apis)

  # Przekazywanie uproszczonych struktur zasobów i uprawnień
  storage_buckets      = each.value.storage_buckets
  bigquery_datasets    = each.value.bigquery_datasets
  iam_roles            = each.value.iam_roles
  repositories         = each.value.repositories

  # Dane globalne dla całego folderu UMP
  org_id               = local.org_id  # var.org_id 
  folder_id            = local.folder_id  # var.folder_id
  billing_account      = local.billing_account  #var.billing_account
}
