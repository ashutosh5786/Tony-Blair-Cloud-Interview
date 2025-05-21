#!/bin/bash

set -e

echo "🚀 [k8s] Applying Kubernetes manifests..."

kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

# Wait for the pod to be in Running state
echo "⏳ Waiting for pod to be in 'Running' state..."
while [[ $(kubectl get pods -l app=ml-serving -o jsonpath="{.items[0].status.phase}") != "Running" ]]; do
  sleep 2
done

read -p "➡️  Do you want to port-forward the app to localhost:8000? (y/n): " forward
# ...existing code...
read -p "➡️  Do you want to port-forward the app to localhost:8000? (y/n): " forward
if [[ "$forward" == "y" ]]; then
  kubectl port-forward svc/ml-serving 8000:80
fi

echo "✅ [k8s] App deployed to cluster."
