terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.9.0"
    }
    consul = {
      source  = "hashicorp/consul"
      version = "~> 2.20.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.29.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12.1"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.14.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }
  }

  required_version = ">= 1.2.0"
}

provider "google" {
  zone = var.zone
  project = var.project
}

provider "kubernetes" {
  host  = "https://${data.google_container_cluster.learn-consul-sameness-dc2.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.learn-consul-sameness-dc2.master_auth[0].cluster_ca_certificate,
  )
}

provider "helm" {
  kubernetes {
    host  = "https://${data.google_container_cluster.learn-consul-sameness-dc2.endpoint}"
    token = data.google_client_config.provider.access_token
    cluster_ca_certificate = base64decode(
      data.google_container_cluster.learn-consul-sameness-dc2.master_auth[0].cluster_ca_certificate,
    )
  }
}

provider "kubectl" {
  host  = "https://${data.google_container_cluster.learn-consul-sameness-dc2.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.learn-consul-sameness-dc2.master_auth[0].cluster_ca_certificate,
  )
  load_config_file = false
}
