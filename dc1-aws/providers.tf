terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.34.0"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "~> 0.79.0"
    }
    consul = {
      source  = "hashicorp/consul"
      version = "~> 2.20.0"
    }
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
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5.1"
    }
    kustomization = {
      source  = "kbst/kustomization"
      version = "0.7.2"
    }
  }

  provider_meta "hcp" {
    module_name = "hcp-consul"
  }

  required_version = ">= 1.2.0"
}

provider "hcp" {
}

provider "aws" {
  region = var.vpc_region
}

data "aws_availability_zones" "available" {
  state = "available"

  filter {
    name   = "opt-in-status"
    values = ["opt-in-not-required"]
  }
}

provider "consul" {
  address = hcp_consul_cluster.main.consul_public_endpoint_url
  token   = hcp_consul_cluster_root_token.token.secret_id
}
