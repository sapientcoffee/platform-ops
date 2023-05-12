terraform {
  backend "gcs" {
    bucket  = "coffee-terraform"
    prefix  = "terraform/state/workstations"
  }
}