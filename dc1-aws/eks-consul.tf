# Create consul namespace
resource "kubernetes_namespace" "consul" {
  metadata {
    name = "consul"
  }
}

resource "kubernetes_secret" "consul_secrets" {
  metadata {
    name      = "${hcp_consul_cluster.main.datacenter}-hcp"
    namespace = "consul"
  }

  data = {
    caCert              = base64decode(hcp_consul_cluster.main.consul_ca_file)
    gossipEncryptionKey = jsondecode(base64decode(hcp_consul_cluster.main.consul_config_file))["encrypt"]
    bootstrapToken      = hcp_consul_cluster_root_token.token.secret_id
  }

  type = "Opaque"

  depends_on = [module.eks]
}

# Create Consul deployment
resource "helm_release" "consul" {
  name       = "consul"
  repository = "https://helm.releases.hashicorp.com"
  version    = var.consul_chart_version
  chart      = "consul"
  namespace  = "consul"
  wait       = true
  timeout    = 900 # 15mins timeout to avoid having to re-run `terraform destroy`

  values = [
    templatefile("${path.module}/../k8s-yamls/consul-helm-dc1.yaml",{
      consul_version = var.consul_version,
      consul_hosts     = trim(hcp_consul_cluster.main.consul_private_endpoint_url, "https://"),
      cluster_id       = hcp_consul_cluster.main.datacenter,
      k8s_api_endpoint = module.eks.cluster_endpoint,
    })
  ]

  depends_on = [module.eks,
                module.eks.eks_managed_node_groups,
                kubernetes_namespace.consul,
                module.vpc,
                ]
}

## Create API Gateway
data "kubectl_path_documents" "api_gw_manifests" {
  pattern = "${path.module}/../k8s-yamls/api-gateway*.yaml"
}

resource "kubectl_manifest" "api_gw" {
  for_each   = toset(data.kubectl_path_documents.api_gw_manifests.documents)
  yaml_body  = each.value
  depends_on = [helm_release.consul]
}

locals {
  # non-default context name to protect from using wrong kubeconfig
  kubeconfig_context = "_terraform-kubectl-context-${local.cluster_name}_"

  kubeconfig = {
    apiVersion = "v1"
    clusters = [
      {
        name = local.kubeconfig_context
        cluster = {
          certificate-authority-data = data.aws_eks_cluster.cluster.certificate_authority.0.data
          server                     = data.aws_eks_cluster.cluster.endpoint
        }
      }
    ]
    users = [
      {
        name = local.kubeconfig_context
        user = {
          token = data.aws_eks_cluster_auth.cluster.token
        }
      }
    ]
    contexts = [
      {
        name = local.kubeconfig_context
        context = {
          cluster   = local.kubeconfig_context
          user      = local.kubeconfig_context
          namespace = "consul"
        }
      }
    ]
  }
}