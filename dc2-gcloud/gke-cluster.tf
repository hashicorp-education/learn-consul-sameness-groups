resource "google_project_service" "svc" {
  project = var.project

  service = "${each.value}.googleapis.com"

  disable_dependent_services = true

  for_each = toset([
    "container",
  ])
}

resource "google_container_cluster" "learn-consul-sameness-dc2" {
  name = "learn-consul-sameness-dc2"
  project = var.project
  location = var.zone
  initial_node_count = 3
  deletion_protection = false
  
  node_config {
    machine_type = "e2-highcpu-4"
  }

  depends_on = [
    google_project_service.svc["container"]
  ]
}

data "google_client_config" "provider" {}

data "google_container_cluster" "learn-consul-sameness-dc2" {
  name     = "learn-consul-sameness-dc2"
  location = var.zone

  depends_on = [ google_container_cluster.learn-consul-sameness-dc2 ]
}

module "gke_auth" {
  source               = "terraform-google-modules/kubernetes-engine/google//modules/auth"

  project_id           = var.project
  cluster_name         = "learn-consul-sameness-dc2"
  location             = var.zone
  use_private_endpoint = true

  depends_on = [ google_container_cluster.learn-consul-sameness-dc2 ]
}
