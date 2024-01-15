variable "project" {
  type = string
  description = "Google Cloud project"
}

variable "zone" {
  type = string
  description = "Google Cloud zone for first cluster"
  default = "us-central1-a"
}

variable "consul_version" {
  type        = string
  description = "The Consul enterprise version to use"
  default     = "1.17.1-ent"
}
