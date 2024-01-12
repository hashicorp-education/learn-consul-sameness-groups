# Create consul namespace
resource "kubernetes_namespace" "consul" {
  metadata {
    name = "consul"
  }
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
    templatefile("${path.module}/../k8s-yamls/consul-helm-dc2.yaml",{
      consul_version = var.consul_version
    })
  ]

  depends_on = [ kubernetes_namespace.consul ]
}

## Create API Gateway
data "kubectl_path_documents" "api_gw_manifests" {
  pattern = "${path.module}/../k8s-yamls/api-gateway*.yaml"
}

resource "kubectl_manifest" "api_gw" {
  for_each   = toset(data.kubectl_path_documents.api_gw_manifests.documents)
  yaml_body  = each.value
  depends_on = [helm_release.consul, kubectl_manifest.hashicups]
}