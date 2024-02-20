terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.9.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "google" {
  zone = var.zone
  project = var.project
}
