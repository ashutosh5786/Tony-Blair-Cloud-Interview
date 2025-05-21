#!/bin/bash

set -e

# -------------------------------
# Helper Functions
# -------------------------------

ask() {
  local prompt="$1"
  read -p "$prompt (y/n): " choice
  case "$choice" in
    y|Y ) return 0 ;;
    * ) return 1 ;;
  esac
}

# -------------------------------
# Setup
# -------------------------------

CLUSTER_NAME="ml-cluster"
AWS_REGION="eu-west-2"
IMAGE_NAME="ml-serving"
IMAGE_TAG="latest"
ECR_REGISTRY="<your-dockerhub-or-ecr-url>" # optional, use local image if not pushing

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# -------------------------------
# Steps
# -------------------------------

echo "🧠 ML Serving Setup Script (TUI Mode)"
echo "======================================"

if ask "1️⃣ Provision EKS with Terraform?"; then
  echo "📁 Switching to iac/ directory..."
  cd "$PROJECT_ROOT/iac"
  terraform init
  terraform apply -auto-approve
  cd "$PROJECT_ROOT"
fi

if ask "2️⃣ Update kubeconfig for EKS cluster access?"; then
  echo "📡 Configuring kubeconfig..."
  aws eks --region "$AWS_REGION" update-kubeconfig --name "$CLUSTER_NAME"
fi

if ask "3️⃣ Install Prometheus & Grafana (Helm)?"; then
  echo "📦 Installing kube-prometheus-stack..."
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
  helm repo update

  kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

  helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
    --namespace monitoring \
    --set grafana.enabled=true \
    --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false

  echo "⏳ Waiting for Grafana deployment..."
  kubectl rollout status deployment/kube-prometheus-stack-grafana -n monitoring
fi

if ask "4️⃣ Build Docker image for the app?"; then
  echo "🐳 Building Docker image..."
  cd "$PROJECT_ROOT/serving"
  docker build -t $IMAGE_NAME:$IMAGE_TAG .
  cd "$PROJECT_ROOT"
fi

if ask "5️⃣ Deploy app to Kubernetes?"; then
  echo "🚀 Applying k8s manifests..."
  kubectl apply -f "$PROJECT_ROOT/k8s/"
fi

if ask "6️⃣ Port-forward Grafana to http://localhost:3000?"; then
  echo "🌐 Access Grafana at http://localhost:3000 (default: admin / prom-operator)"
  kubectl port-forward svc/kube-prometheus-stack-grafana -n monitoring 3000:80
fi

echo "✅ All done!"
