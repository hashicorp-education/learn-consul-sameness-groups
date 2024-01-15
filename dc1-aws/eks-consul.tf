locals {
  helm_chart_consul = <<-EOT
    global:
      enabled: true
      name: consul
      datacenter: ${hcp_consul_cluster.main.datacenter}
      image: "hashicorp/consul-enterprise:1.17.1-ent"
      peering:
        enabled: true
      tls:
        enabled: true # mandatory for cluster peering
        enableAutoEncrypt: true
        verify: true
        caCert:
          secretName: ${hcp_consul_cluster.main.datacenter}
          secretKey: caCert
      acls:
        manageSystemACLs: true
        bootstrapToken:
          secretName: ${hcp_consul_cluster.main.datacenter}
          secretKey: bootstrapToken

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
      k8sAuthMethodHost: ${module.eks.cluster_endpoint}:443

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

resource "local_file" "helm_chart_consul" {
  filename = "${path.module}/../k8s-yamls/consul-helm-dc1.yaml"
  content  = local.helm_chart_consul
}
