# WordPress on Kubernetes - Complete Production Deployment

Production-ready WordPress deployment on Kubernetes with MySQL StatefulSet, NGINX Ingress, and comprehensive monitoring using Prometheus and Grafana.

## Architecture Overview
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   NGINX Ingress │    │   WordPress      │    │     MySQL       │
│   Controller    │───►│   (2 replicas)   │───►│   StatefulSet   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
│                        │                       │
▼                        ▼                       ▼
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│  LoadBalancer   │    │   ClusterIP      │    │  Persistent     │
│  Service        │    │   Service        │    │  Volume (2Gi)   │
└─────────────────┘    └──────────────────┘    └─────────────────┘
Monitoring: Prometheus + Grafana + AlertManager

## Quick Start

### Prerequisites
- Minikube running
- kubectl configured  
- Helm 3.x installed
- AWS CLI configured for ECR access

### Deploy Everything
```bash
git clone git@github.com:Lirhen/K8s.git
cd K8s
./deployment-scripts/deploy-all.sh
Verify Deployment
bashkubectl get all --all-namespaces
kubectl get pods -n wordpress
kubectl get pods -n monitoring
kubectl get pods -n ingress-nginx
Repository Structure
├── services/
│   ├── wordpress/               # WordPress Application
│   │   ├── namespace.yaml       # WordPress namespace
│   │   ├── secret.yaml          # MySQL credentials
│   │   ├── mysql-pvc.yaml       # Persistent volume claim
│   │   ├── mysql-statefulset.yaml # MySQL database
│   │   ├── mysql-service.yaml   # MySQL service
│   │   ├── wordpress-deployment.yaml # WordPress app
│   │   ├── wordpress-service.yaml # WordPress service
│   │   ├── wordpress-ingress.yaml # External access
│   │   ├── create-ecr-secret.sh # ECR authentication
│   │   └── helm-chart/          # Helm chart version
│   ├── ingress/                 # NGINX Ingress Controller
│   └── monitoring/              # Prometheus/Grafana stack
├── deployment-scripts/          # Automated deployment
│   ├── 01-deploy-ingress.sh    # NGINX Ingress setup
│   ├── 02-deploy-wordpress.sh  # WordPress deployment
│   ├── 03-deploy-monitoring.sh # Monitoring stack
│   └── deploy-all.sh           # Complete deployment
└── docs/                       # Additional documentation
Components Deployed
WordPress Application

WordPress: 2 replicas with rolling updates
MySQL: StatefulSet with persistent storage (2Gi)
Storage: PersistentVolumeClaim for database
Security: Kubernetes Secrets for credentials
Images: Stored in AWS ECR private registry

Networking

Ingress: NGINX Ingress Controller for external access
Services: ClusterIP for internal communication
DNS: Internal service discovery

Monitoring Stack

Prometheus: Metrics collection and storage
Grafana: Visualization dashboards
AlertManager: Alert routing and management
ServiceMonitors: Automatic Kubernetes metrics discovery

Access Applications
WordPress Application
bashkubectl port-forward -n wordpress svc/wordpress-service 8080:80 --address=0.0.0.0 &
# Access: http://your-server-ip:8080
Grafana Dashboard
bash# Get admin password
kubectl get secret -n monitoring monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 --decode

# Port forward
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80 --address=0.0.0.0 &
# Access: http://your-server-ip:3000 (user: admin)
Prometheus
bashkubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090 --address=0.0.0.0 &
# Access: http://your-server-ip:9090
Monitoring and Observability
Container Uptime Panel
Custom Grafana panel monitoring WordPress containers:
promqlkube_pod_container_status_running{namespace="wordpress"}
Key Metrics Monitored

Container uptime and restart counts
Resource utilization (CPU, memory)
Network traffic and response times
Database connections and performance
Application health checks

Grafana Dashboards

Kubernetes Cluster Overview
WordPress Application Health
MySQL Database Performance
Container Resource Usage
Network and Ingress Metrics

Manual Deployment Steps
If you prefer step-by-step deployment:
1. Deploy NGINX Ingress
bash./deployment-scripts/01-deploy-ingress.sh
2. Deploy WordPress
bash./deployment-scripts/02-deploy-wordpress.sh
3. Deploy Monitoring
bash./deployment-scripts/03-deploy-monitoring.sh
Configuration
Database Configuration

MySQL 5.7 with persistent storage
Credentials stored in Kubernetes Secrets
StatefulSet ensures stable network identity
2Gi persistent volume for data

WordPress Configuration

2 replicas for high availability
Rolling update deployment strategy
Health checks (readiness/liveness probes)
Resource limits: 512Mi memory, 500m CPU

Security Features

Private ECR registry for images
Kubernetes Secrets for credentials
Service accounts with minimal privileges
Network policies ready for implementation

Troubleshooting
Common Issues
Pods in ImagePullBackOff:
bashkubectl describe pod <pod-name> -n wordpress
# Check ECR authentication
Database Connection Failed:
bashkubectl logs -n wordpress mysql-0
kubectl get secret mysql-secret -n wordpress -o yaml
Ingress Not Working:
bashkubectl describe ingress wordpress-ingress -n wordpress
kubectl get pods -n ingress-nginx
Grafana Not Accessible:
bashkubectl get pods -n monitoring | grep grafana
kubectl logs -n monitoring -l "app.kubernetes.io/name=grafana"
Verification Commands
bash# Check all resources
kubectl get all -n wordpress
kubectl get all -n monitoring
kubectl get all -n ingress-nginx

# Verify persistent volumes
kubectl get pvc -n wordpress
kubectl get pvc -n monitoring

# Check resource usage
kubectl top pods -n wordpress
kubectl top nodes
Cleanup
To remove all deployed resources:
bashkubectl delete namespace wordpress
kubectl delete namespace monitoring  
kubectl delete namespace ingress-nginx
Technical Details
Migration from Docker Compose
Original docker-compose.yml components mapped to Kubernetes:
Docker ComposeKubernetes Resourcewordpress serviceDeployment + Service + Ingressdb serviceStatefulSet + Service + PVCvolumesPersistentVolumeClaimnetworksKubernetes networkingenvironmentSecrets + ConfigMaps
Resource Specifications

WordPress pods: 256Mi-512Mi memory, 100m-500m CPU
MySQL pod: 256Mi-512Mi memory, 100m-500m CPU
Storage: 2Gi for MySQL data, 1Gi for Grafana
Network: ClusterIP services with Ingress exposure

High Availability Features

Multiple WordPress replicas
StatefulSet for database stability
Persistent storage for data
Health checks and auto-recovery
Rolling updates with zero downtime

License
MIT License - see LICENSE file for details.
Support
For issues:

Check troubleshooting section
Review pod logs: kubectl logs <pod-name> -n <namespace>
Check resource status: kubectl describe <resource> <name> -n <namespace>
