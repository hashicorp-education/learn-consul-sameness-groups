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
kubectl --context=dc2 apply -f hashicups-v1.0.2/
kubectl --context=dc2 apply -f k8s-yamls/api-gateway.yaml

# go to https://portal.cloud.hashicorp.com/services/consul/clusters
## Create or link a Consul cluster

## click click click

kubectl config set-context dc2

## set up dc2 k8s secrets from consul UI here

## connect dc2 to hcp
consul-k8s upgrade -context=dc2 -config-file <(consul-k8s config read -context=dc2) -config-file ./hcp-values.yaml


## Click on Cluster Peering left of the HCP Consul Dashboard
## Click on Create Connection

##
kubectl --context=dc1 apply -f k8s-yamls/dc1-sg-hashicups.yaml
kubectl --context=dc2 apply -f k8s-yamls/dc2-sg-hashicups.yaml

kubectl --context=dc2 apply -f k8s-yamls/exp-hashicups.yaml

kubectl --context=dc2 apply -f k8s-yamls/intentions-samenessgroup.yaml
