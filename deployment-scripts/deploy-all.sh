#!/bin/bash
echo "Starting Full WordPress Kubernetes Deployment..."

./deployment-scripts/01-deploy-ingress.sh
./deployment-scripts/02-deploy-wordpress.sh  
./deployment-scripts/03-deploy-monitoring.sh

echo "All services deployed successfully!"
echo ""
echo "Access services with:"
echo "WordPress: kubectl port-forward -n wordpress svc/wordpress-service 8080:80 --address=0.0.0.0"
echo "Grafana: kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80 --address=0.0.0.0"
echo "Prometheus: kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090 --address=0.0.0.0"
