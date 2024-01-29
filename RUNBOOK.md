## Runbook

```

# prep DC1
terraform -chdir=dc1-aws init
terraform -chdir=dc1-aws apply
aws eks --region $(terraform -chdir=dc1-aws output -raw region) update-kubeconfig --name $(terraform -chdir=dc1-aws output -raw cluster_name) --alias=dc1
kubectl --context=dc1 create namespace consul
kubectl --context=dc1 --namespace=consul create secret generic $(terraform -chdir=dc1-aws output -raw consul_datacenter) --from-literal="caCert=$(terraform -chdir=dc1-aws output -raw hcp_consul_ca)" --from-literal="bootstrapToken=$(terraform -chdir=dc1-aws output -raw consul_token)"
consul-k8s install -context=dc1 -config-file=k8s-yamls/consul-helm-dc1.yaml
kubectl --context=dc1 apply -f hashicups-v1.0.2/
kubectl --context=dc1 apply -f k8s-yamls/api-gateway.yaml

# prep DC2
terraform -chdir=dc2-gcloud init
terraform -chdir=dc2-gcloud apply
gcloud config set project $(terraform -chdir=dc2-gcloud output -raw project_id)
gcloud container clusters get-credentials --zone $(terraform -chdir=dc2-gcloud output -raw zone) demodatacenter2
kubectl config rename-context gke_$(terraform -chdir=dc2-gcloud output -raw project)_ $(terraform -chdir=dc2-gcloud output -raw zone)_demodatacenter2 dc2
kubectl --context=dc2 create namespace consul
kubectl --context=dc2 --namespace=consul create secret generic consul-license --from-file="key=consul.hclic"
consul-k8s install -context=dc2 -config-file=k8s-yamls/consul-helm-dc2.yaml
kubectl --context=dc2 apply -f hashicups-v1.0.2/
kubectl --context=dc2 apply -f k8s-yamls/api-gateway.yaml


# Link Consul cluster from DC2
## go to https://portal.cloud.hashicorp.com/services/consul/clusters
## Click on Create or link a Consul cluster
## Follow the instructions, name the cluster `demodatacenter2` until the CLI commands step
kubectl config set-context dc2
## Paste the command for the DC2 K8s secrets from Consul UI here
consul-k8s upgrade -context=dc2 -config-file <(consul-k8s config read -context=dc2) -config-file ./hcp-values.yaml # connect DC to HCP

# Peer the two clusters using the HCP Consul UI
## Click on Cluster Peering left of the HCP Consul Dashboard
## Click on Create Connection
## Set demodatacenter1 as the Peering Acceptor
## Wait for peering to complete

# Set up SamenessGroups
kubectl --context=dc1 apply -f k8s-yamls/dc1-sg-hashicups.yaml
kubectl --context=dc2 apply -f k8s-yamls/dc2-sg-hashicups.yaml

# Export `public-api` and `products-api` from DC2 into DC1  
kubectl --context=dc2 apply -f k8s-yamls/exp-hashicups.yaml

# Apply intentions that allow cross-DC access via the SamenessGroup
kubectl --context=dc2 apply -f k8s-yamls/intentions-samenessgroup.yaml

kubectl --context=dc1 delete -f hashicups-v1.0.2/public-api.yaml

# Observe that the coffee inventory still shows in the HashiCups UI
```