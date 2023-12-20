terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.24.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
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

provider "kubernetes" {
  host  = "https://${data.google_container_cluster.dc1.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.dc1.master_auth[0].cluster_ca_certificate,
  )
}

provider "helm" {
  kubernetes {
    host  = "https://${data.google_container_cluster.dc1.endpoint}"
    token = data.google_client_config.provider.access_token
    cluster_ca_certificate = base64decode(
      data.google_container_cluster.dc1.master_auth[0].cluster_ca_certificate,
    )
  }
}

provider "kubectl" {
  host  = "https://${data.google_container_cluster.dc1.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.dc1.master_auth[0].cluster_ca_certificate,
  )
  load_config_file = false
}
