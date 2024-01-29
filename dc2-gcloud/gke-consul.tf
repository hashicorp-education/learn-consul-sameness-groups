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

resource "local_file" "helm_chart_consul" {
  filename = "${path.module}/../k8s-yamls/consul-helm-dc2.yaml"
  content  = local.helm_chart_consul
}
