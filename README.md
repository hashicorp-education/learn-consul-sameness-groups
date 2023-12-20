# Learn Consul Cluster Peering

This is a companion repo to the [Connect Services in Different Consul Clusters with Cluster Peering tutorial](https://developer.hashicorp.com/consul/tutorials/developer-mesh/cluster-peering-aws), containing sample configuration to:

- Deploy two Kubernetes clusters with Consul
- Deploy HashiCups frontend in the first Kubernetes cluster
- Deploy HashiCups backend in the second Kubernetes cluster
- Configure Consul cluster peering between the two clusters
- Export the HashiCups `products-api` service in the second datacenter 
- Connect the HashiCups frontend and backend via the cluster peering
- Verify peered Consul services
- Destroy environment

# Thanks

This repository has borrowed code from the following other repositories. Thank you!

- https://github.com/vanphan24/cluster-peering-demo
- https://github.com/hashicorp/learn-terraform-provision-aks-cluster
