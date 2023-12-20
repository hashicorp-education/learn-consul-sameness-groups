terraform -chdir=dc1-aws init
terraform -chdir=dc1-aws apply
aws eks --region $(terraform -chdir=dc1-aws output -raw region) update-kubeconfig --name $(terraform -chdir=dc1-aws output -raw cluster_name) --alias=dc1


terraform -chdir=dc2-gcloud init
