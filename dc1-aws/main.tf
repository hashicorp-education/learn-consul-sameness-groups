locals {
  cluster_name = "${var.name}-${random_string.suffix.result}"
  name         = "${var.name}-${random_string.suffix.result}"
  hvn_id       = "${var.hvn_id}-${random_string.suffix.result}"
}

resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}
