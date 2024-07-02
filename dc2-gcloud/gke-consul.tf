locals {
  helm_chart_consul = <<EOT
global:
  name: consul
  datacenter: learn-consul-sameness-dc2
  image: "hashicorp/consul-enterprise:${var.consul_version}"
  peering:
    enabled: true
  enableConsulNamespaces: true
  tls:
    enabled: true # mandatory for cluster peering
    enableAutoEncrypt: true
    verify: true
  acls:
    manageSystemACLs: true
  metrics:
    enabled: true
    enableGatewayMetrics: true
  enterpriseLicense:
    secretName: consul-license
    secretKey: key

dns:
  enabled: true
  enableRedirection: true

server:
  enabled: true
  replicas: 3
  extraConfig: |
    {
      "log_level": "TRACE"
    }

connectInject:
  transparentProxy:
    defaultEnabled: true
  enabled: true
  default: true
  metrics:
    defaultEnabled: true # by default, this inherits from the value global.metrics.enabled
    defaultEnableMerging: false

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

resource "kubernetes_namespace" "consul" {
  metadata {
    name = "consul"
  }

  depends_on = [ google_container_cluster.learn-consul-sameness-dc2 ]
}

# Create Kubernetes secrets for Consul components
resource "kubernetes_secret" "consul_license" {
  metadata {
    name = "consul-license"
    namespace = "consul"
  }

  data = {
    key = file("${path.module}/../consul.hclic")
  }

  depends_on = [
    #google_container_cluster.learn-consul-sameness-dc2, 
    kubernetes_namespace.consul,
  ]

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

  values = [
    local.helm_chart_consul,
  ]

  depends_on = [
    kubernetes_namespace.consul,
    kubernetes_secret.consul_license,
    google_container_cluster.learn-consul-sameness-dc2,
  ]
}

## Create API Gateway
data "kubectl_path_documents" "api_gw_manifests" {
  pattern = "${path.module}/../k8s-yamls/api-gateway*.yaml"
}

resource "kubectl_manifest" "api_gw" {
  for_each   = toset(data.kubectl_path_documents.api_gw_manifests.documents)
  yaml_body  = each.value
  depends_on = [
    helm_release.consul,
    kubectl_manifest.hashicups,
  ]
}
