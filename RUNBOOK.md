terraform -chdir=dc1-aws init
terraform -chdir=dc1-aws apply
aws eks --region $(terraform -chdir=dc1-aws output -raw region) update-kubeconfig --name $(terraform -chdir=dc1-aws output -raw cluster_name) --alias=dc1
kubectl --context=dc1 create namespace consul
kubectl --context=dc1 --namespace=consul create secret generic $(terraform -chdir=dc1-aws output -raw consul_datacenter) --from-literal="caCert=$(terraform -chdir=dc1-aws output -raw hcp_consul_ca)" --from-literal="bootstrapToken=$(terraform -chdir=dc1-aws output -raw consul_token)"
consul-k8s install -context=dc1 -config-file=k8s-yamls/consul-helm-dc1.yaml
kubectl --context=dc1 apply -f hashicups-v1.0.2/
kubectl --context=dc1 apply -f k8s-yamls/api-gateway.yaml

terraform -chdir=dc2-gcloud init
terraform -chdir=dc2-gcloud apply

gcloud config set project hc-f7aeccc6321b46ccb29e97f1481
gcloud container clusters get-credentials --zone us-central1-a dc2
kubectl config rename-context gke_hc-f7aeccc6321b46ccb29e97f1481_us-central1-a_dc2 dc2

kubectl --context=dc2 create namespace consul
kubectl --context=dc2 --namespace=consul create secret generic consul-license --from-file="key=consul.hclic"
consul-k8s install -context=dc2 -config-file=k8s-yamls/consul-helm-dc2.yaml

# go to https://portal.cloud.hashicorp.com/services/consul/clusters
## Create or link a Consul cluster

## click click click

kubectl config set-context dc2

kubectl create secret generic consul-hcp-client-id --from-literal=client-id='IWfi1Lhs5D2ZiRSZRfHxppYGt5ULPwmv' --namespace consul

kubectl create secret generic consul-hcp-client-secret --from-literal=client-secret='gcnL9LGEniOECiahBYn3fbMknmhpr6hXLl7wChdolMNH7vGMcve24abLBdmFaZPz' --namespace consul

kubectl create secret generic consul-hcp-observability-client-id --from-literal=client-id='VHWTZ42lklWiSPgHGsx3GRpvs83BiOGu' --namespace consul

kubectl create secret generic consul-hcp-observability-client-secret --from-literal=client-secret='O0GNTvBYjwEmHZ9HPXkBJAUMLvAmpXSDsmNAZunHubkFk8DCIKAwzh2c1A166ZT4' --namespace consul

kubectl create secret generic consul-hcp-resource-id --from-literal=resource-id='organization/067acbc1-ed49-4dc2-9fcb-6b4aff713469/project/3eecc579-d274-4792-ae72-22d2035a4c1d/hashicorp.consul.global-network-manager.cluster/dc2' --namespace consul

echo "global:
  cloud:
    enabled: true
    resourceId:
      secretName: consul-hcp-resource-id
      secretKey: resource-id
    clientId:
      secretName: consul-hcp-client-id
      secretKey: client-id
    clientSecret:
      secretName: consul-hcp-client-secret
      secretKey: client-secret
  metrics:
    enableTelemetryCollector: true
telemetryCollector:
  enabled: true
  cloud:
    clientId:
      secretKey: client-id
      secretName: consul-hcp-observability-client-id
    clientSecret:
      secretKey: client-secret
      secretName: consul-hcp-observability-client-secret" > hcp-values.yaml

consul-k8s upgrade -config-file <(consul-k8s config read) -config-file ./hcp-values.yaml

==> Checking if Consul can be upgraded
 ✓ Existing Consul installation found to be upgraded.
    Name: consul
    Namespace: consul

==> Checking if Consul demo application can be upgraded
    No existing Consul demo application installation found.

==> Consul Upgrade Summary
 ✓ Downloaded charts.
    
    Difference between user overrides for current and upgraded charts
    -----------------------------------------------------------------
    connectInject:
      default: true
      enabled: true
      metrics:
        defaultEnableMerging: false
        defaultEnabled: true
      transparentProxy:
        defaultEnabled: true
    dns:
      enableRedirection: true
      enabled: true
    global:
      acls:
        manageSystemACLs: true
  +   cloud:
  +     clientId:
  +       secretKey: client-id
  +       secretName: consul-hcp-client-id
  +     clientSecret:
  +       secretKey: client-secret
  +       secretName: consul-hcp-client-secret
  +     enabled: true
  +     resourceId:
  +       secretKey: resource-id
  +       secretName: consul-hcp-resource-id
      datacenter: dc2
      image: hashicorp/consul-enterprise:1.17.1-ent
      metrics:
        enableGatewayMetrics: true
        enableTelemetryCollector: true
        enabled: true
      name: consul
      peering:
        enabled: true
      tls:
        enableAutoEncrypt: true
        enabled: true
        verify: true
    meshGateway:
      enabled: true
      replicas: 1
    prometheus:
      enabled: true
    server:
      enabled: true
      extraConfig: |
        {
          "log_level": "TRACE"
        }
      replicas: 3
    telemetryCollector:
  +   cloud:
  +     clientId:
  +       secretKey: client-id
  +       secretName: consul-hcp-observability-client-id
  +     clientSecret:
  +       secretKey: client-secret
  +       secretName: consul-hcp-observability-client-secret
      enabled: true
    ui:
      enabled: true
      metrics:
        baseURL: http://prometheus-server
        enabled: true
        provider: prometheus
      service:
        enabled: true
        type: LoadBalancer
  
    Proceed with upgrade? (Y/n) y

==> Upgrading Consul
 --> preparing upgrade for consul
 --> performing update for consul
 --> creating upgraded release for consul
 ##...
 --> waiting for release consul resources (created: 1 updated: 92  deleted: 0)
 --> beginning wait for 93 resources with timeout of 10m0s
 ##...
 --> updating status for upgraded release for consul
 ✓ Consul upgraded in namespace "consul".

## Click on Cluster Peering left of the HCP Consul Dashboard
## Click on Create Connection

##
kubectl --contex=dc1 apply -f k8s-yamls/dc1-sg-hashicups.yaml
kubectl --contex=dc2 apply -f k8s-yamls/dc2-sg-hashicups.yaml

kubectl --contex=dc2 apply -f k8s-yamls/exp-hashicups.yaml

kubectl --contex=dc2 apply -f k8s-yamls/intentions-samenessgroup.yaml
