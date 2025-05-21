#!/bin/bash

set -e

echo "📊 [monitoring] Installing Prometheus + Grafana..."

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true
helm repo update

kubectl create namespace monitoring --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --set grafana.enabled=true \
  --set prometheus.prometheusSpec.serviceMonitorSelectorNilUsesHelmValues=false

echo "⏳ Waiting for Grafana to be ready..."
kubectl rollout status deployment/kube-prometheus-stack-grafana -n monitoring

echo "✅ [monitoring] Monitoring stack installed."
