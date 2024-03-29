# The HVN created in HCP
resource "hcp_hvn" "main" {
  hvn_id         = local.hvn_id
  cloud_provider = "aws"
  region         = var.hvn_region
  cidr_block     = var.hvn_cidr_block
}

module "aws_hcp_consul" {
  source  = "hashicorp/hcp-consul/aws"
  version = "~> 0.13.0"

  hvn                = hcp_hvn.main
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = concat(module.vpc.public_subnets)
  route_table_ids    = concat(module.vpc.public_route_table_ids)
  security_group_ids = [module.eks.cluster_primary_security_group_id]
}

resource "hcp_consul_cluster" "main" {
  cluster_id         = local.cluster_name
  hvn_id             = hcp_hvn.main.hvn_id
  public_endpoint    = true
  tier               = var.consul_tier
  min_consul_version = var.consul_version
}

resource "hcp_consul_cluster_root_token" "token" {
  cluster_id = hcp_consul_cluster.main.id
}
