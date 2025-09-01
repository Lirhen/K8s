#!/bin/bash
echo "Deploying NGINX Ingress Controller..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install my-release ingress-nginx/nginx-ingress --namespace ingress-nginx --create-namespace
kubectl wait --namespace ingress-nginx --for=condition=ready pod --selector=app.kubernetes.io/component=controller --timeout=120s
echo "NGINX Ingress Controller deployed successfully"
