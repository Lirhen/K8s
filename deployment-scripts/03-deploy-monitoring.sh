#!/bin/bash
echo "Deploying Monitoring Stack..."

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --set grafana.persistence.enabled=false \
  --set prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage=2Gi

kubectl wait --for=condition=ready pod --all -n monitoring --timeout=600s

echo "Monitoring stack deployed successfully"
