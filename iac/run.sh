#!/bin/bash

set -e

echo "📁 [iac] Running Terraform to provision EKS..."

terraform init
terraform apply -auto-approve

# Optional kubeconfig update
read -p "➡️  Do you want to update kubeconfig now? (y/n): " update
if [[ "$update" == "y" ]]; then
  aws eks --region eu-west-2 update-kubeconfig --name ml-cluster
fi

echo "✅ [iac] EKS setup complete."

