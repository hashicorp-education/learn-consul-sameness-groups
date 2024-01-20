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

output "vpc" {
  value = {
    vpc_id         = module.vpc.vpc_id
    vpc_cidr_block = module.vpc.vpc_cidr_block
    hvn_cidr_block = var.hvn_cidr_block
  }
}

output "hcp_consul_ca" {
  value = base64decode(hcp_consul_cluster.main.consul_ca_file)
  sensitive = true
}

output "next_steps" {
  value = <<-EOT
    aws eks --region $(terraform -chdir=dc1-aws output -raw region) update-kubeconfig --name $(terraform -chdir=dc1-aws output -raw cluster_name) --alias=dc1
    kubectl --context=dc1 create namespace consul
    kubectl --context=dc1 --namespace=consul create secret generic ${hcp_consul_cluster.main.datacenter} --from-literal="caCert=$(terraform -chdir=dc1-aws output -raw hcp_consul_ca)" --from-literal="bootstrapToken=$(terraform -chdir=dc1-aws output -raw consul_token)"
    consul-k8s install -context=dc1 -config-file=k8s-yamls/consul-helm-dc1.yaml
  EOT
}