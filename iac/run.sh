terraform init
terraform apply -auto-approve

## After the cluster is created, we need to update the kubeconfig file to use the new cluster
aws eks --region eu-west-2 update-kubeconfig --name ml-cluster
kubectl get nodes

# Once the cluster is up and running, we can install the monitoring stack
chmod +x iac/install-monitoring.sh
