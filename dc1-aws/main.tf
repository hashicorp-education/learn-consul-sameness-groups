locals {
  cluster_name = "learn-consul-sameness-dc1"
  hvn_id       = "${var.hvn_id}-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}
