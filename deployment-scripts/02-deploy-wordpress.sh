#!/bin/bash
echo "Deploying WordPress Application..."

# ECR Authentication
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 992382545251.dkr.ecr.us-east-1.amazonaws.com

# Deploy WordPress services
kubectl apply -f services/wordpress/namespace.yaml
kubectl apply -f services/wordpress/secret.yaml
kubectl apply -f services/wordpress/mysql-pvc.yaml
kubectl apply -f services/wordpress/mysql-statefulset.yaml
kubectl apply -f services/wordpress/mysql-service.yaml

# Create ECR secret
services/wordpress/create-ecr-secret.sh

# Deploy WordPress
kubectl apply -f services/wordpress/wordpress-deployment.yaml
kubectl apply -f services/wordpress/wordpress-service.yaml
kubectl apply -f services/wordpress/wordpress-ingress.yaml

# Wait for deployment
kubectl wait --for=condition=available --timeout=300s deployment/wordpress -n wordpress

echo "WordPress deployed successfully"
