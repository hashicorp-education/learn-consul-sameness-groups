terraform {
  required_providers {
    consul = {
      source = "hashicorp/consul"
      version = "2.20.0"
    }
  }
}

provider "consul" {
  address = var.dc1_address
  token = var.dc1_token
  alias = "dc1"
}

provider "consul" {
  address = var.dc2_address
  token = var.dc2_token
  scheme = "https"
  #ca_pem = base64decode(var.dc2_certificateauthority)
  insecure_https = true # workaround for non-production setting where IP allocated to Consul-UI service is dynamic
  alias = "dc2"
}