output "consul_datacenter" {
  value = hcp_consul_cluster.main.datacenter
}

output "consul_token" {
  value     = hcp_consul_cluster_root_token.token.secret_id
  sensitive = true
}

output "cluster_name" {
  value = local.cluster_name
}

output "region" {
  value = var.vpc_region
}

output "hcp_consul_ca" {
  value = base64decode(hcp_consul_cluster.main.consul_ca_file)
  sensitive = true
}
