# ==============================================================================
# Repozytorium Cloud Storage - Definicja Zasobów
# ==============================================================================

resource "google_storage_bucket" "buckets" {
  for_each = toset(var.buckets)                            # Przechodzimy pętlą po prostej liście nazw stringów

  project       = var.gcp_project_id
  name          = each.value                               # Tutaj wpadną kolejno: "value_media_tui", "value_media_dhl" itp.
  location      = "EUROPE-CENTRAL2"                        # Wszystkie domyślnie tworzą się w Warszawie
  force_destroy = false

                                    
  uniform_bucket_level_access = true                      # Wymuszamy jednolite standardy bezpieczeństwa dla każdego z nich:
  public_access_prevention    = "enforced"
  

  autoclass {                                               # Każdy bucket automatycznie dostaje oszczędny Autoclass
    enabled                = true
    terminal_storage_class = "NEARLINE"
  }

  versioning {                                              # Każdy bucket ma włączone wersjonowanie
    enabled = true
  }

  soft_delete_policy {                                        # Każdy bucket chroni dane przez 90 dni za pomocą Soft Delete
    retention_duration_seconds = 90 * 24 * 60 * 60            # 90 dni w sekundach
  }

  lifecycle_rule {                                             # Każdy bucket automatycznie czyści stare wersje po 90 dniach
    action {
      type = "Delete"
    }
    condition {
      with_state = "ARCHIVED"
      age        = 90
    }
  }
}
