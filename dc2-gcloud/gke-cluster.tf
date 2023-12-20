resource "google_project_service" "svc" {
  service = "${each.value}.googleapis.com"

  disable_dependent_services = true

  for_each = toset([
    "container",
  ])
}

resource "google_container_cluster" "dc1" {
  name = "dc1"
  location = var.zone
  initial_node_count = 3
  deletion_protection = false

  depends_on = [
    google_project_service.svc["container"]
  ]
}

data "google_client_config" "provider" {}

data "google_container_cluster" "dc1" {
  name     = "dc1"
  location = var.zone

  depends_on = [ google_container_cluster.dc1 ]
}

module "gke_auth" {
  source               = "terraform-google-modules/kubernetes-engine/google//modules/auth"

  project_id           = var.project
  cluster_name         = "dc1"
  location             = var.zone
  use_private_endpoint = true

  depends_on = [ google_container_cluster.dc1 ]
}
