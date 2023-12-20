# General variables
variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "consul_chart_version" {
  type        = string
  description = "The Consul Helm chart version to use"
  default     = "1.3.0"
}

variable "consul_version" {
  type        = string
  description = "The Consul version to use"
  default     = "1.17.0"
}

# HCP variables
variable "cluster_id" {
  type        = string
  description = "The name of your HCP Consul cluster"
  default     = "learn-consul-sameness"
}


variable "hvn_region" {
  type        = string
  description = "The HCP region to create resources in"
  default     = "us-east-2"
}

variable "hvn_id" {
  type        = string
  description = "The name of your HCP HVN"
  default     = "learn-consul-sameness"
}

variable "hvn_cidr_block" {
  type        = string
  description = "The CIDR range to create the HCP HVN with"
  default     = "172.25.32.0/20"
}

variable "consul_tier" {
  type        = string
  description = "The HCP Consul tier to use when creating a Consul cluster"
  default     = "development"
}
