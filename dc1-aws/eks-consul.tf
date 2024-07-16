locals {
  helm_chart_consul = <<-EOT
    global:
      enabled: true
      name: consul
      datacenter: ${hcp_consul_cluster.main.datacenter}
      peering:
        enabled: true
      enableConsulNamespaces: true
      tls:
        enabled: true # mandatory for cluster peering
        enableAutoEncrypt: true
        verify: true
      acls:
        manageSystemACLs: true
        bootstrapToken:
          secretName: bootstrap-token
          secretKey: token
      metrics:
        enabled: true
        enableGatewayMetrics: true

    dns:
      enabled: true
      enableRedirection: true

    externalServers:
      enabled: true
      hosts: ["${trim(hcp_consul_cluster.main.consul_private_endpoint_url, "https://")}"]
      httpsPort: 443
      useSystemRoots: true
      k8sAuthMethodHost: '${module.eks.cluster_endpoint}:443'

    server:
      enabled: false

    connectInject:
      transparentProxy:
        defaultEnabled: true
      enabled: true
      default: true
      metrics:
        defaultEnabled: true # by default, this inherits from the value global.metrics.enabled
        defaultEnableMerging: false
      apiGateway:
        managedGatewayClass:
          serviceType: LoadBalancer
      consulNode:
        meta:
          terraform-module: "hcp-eks-client"

    meshGateway:
      enabled: true # mandatory for k8s cluster peering
      replicas: 1

    ui:
      enabled: true
      service:
        enabled: true
        type: LoadBalancer
      metrics:
        enabled: true # by default, this inherits from the value global.metrics.enabled
        provider: "prometheus"
        baseURL: http://prometheus-server #prometheus-server.consul.svc.cluster.local

    prometheus:
      enabled: true

  EOT
}

# Create Kubernetes secrets for Consul components
resource "kubernetes_secret" "consul_bootstrap_token" {
  metadata {
    name      = "bootstrap-token"
    namespace = "consul"
  }

  data = {
    token = hcp_consul_cluster_root_token.token.secret_id
  }

  depends_on = [
    #module.eks.eks_managed_node_groups,
    kubernetes_namespace.consul
  ]

}

# Create consul namespace
resource "kubernetes_namespace" "consul" {
  metadata {
    name = "consul"
  }

  depends_on = [ module.eks ]
}

# Create Consul deployment
resource "helm_release" "consul" {
  name       = "consul"
  repository = "https://helm.releases.hashicorp.com"
  version    = var.helm_chart_version
  chart      = "consul"
  namespace  = "consul"
  create_namespace = false
  wait       = true
  wait_for_jobs = true
  timeout    = "900"

  values = [
    local.helm_chart_consul
  ]

  depends_on = [
    #module.eks,
    #module.eks.eks_managed_node_groups,
    kubernetes_namespace.consul,
    kubernetes_secret.consul_bootstrap_token
    #module.vpc,
  ]
}

## Create API Gateway
data "kubectl_path_documents" "api_gw_manifests" {
  pattern = "${path.module}/../k8s-yamls/api-gateway*.yaml"
}

resource "kubectl_manifest" "api_gw" {
  for_each   = toset(data.kubectl_path_documents.api_gw_manifests.documents)
  yaml_body  = each.value
  wait = true
  depends_on = [kubectl_manifest.hashicups]
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
