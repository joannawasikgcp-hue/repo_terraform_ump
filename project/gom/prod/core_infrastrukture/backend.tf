terraform {
  backend "gcs" {
    bucket  = "core-infrastructure-tf-state"
    prefix  = "terraform/state"
  }
}
