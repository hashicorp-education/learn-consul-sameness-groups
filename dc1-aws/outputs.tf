output "cluster_id" {
  description = "EKS cluster ID"
  value       = module.eks.cluster_id
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "cluster_name" {
  description = "Kubernetes Cluster Name"
  value       = local.cluster_name
}

output "consul_token" {
  value     = hcp_consul_cluster_root_token.token.secret_id
  sensitive = true
}

output "vpc" {
  value = {
    vpc_id         = module.vpc.vpc_id
    vpc_cidr_block = module.vpc.vpc_cidr_block
    hvn_cidr_block = var.hvn_cidr_block
  }
}