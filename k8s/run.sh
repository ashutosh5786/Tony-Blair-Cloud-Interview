#!/bin/bash

set -e

echo "🚀 [k8s] Applying Kubernetes manifests..."

kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

sleep 50
read -p "➡️  Do you want to port-forward the app to localhost:8000? (y/n): " forward
if [[ "$forward" == "y" ]]; then
  kubectl port-forward svc/ml-serving 8000:80
fi

echo "✅ [k8s] App deployed to cluster."
