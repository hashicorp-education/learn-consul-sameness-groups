variable "project" {
  type = string
  description = "Google Cloud project"
}

variable "zone" {
  type = string
  description = "Google Cloud zone for first cluster"
  default = "us-central1-a"
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
