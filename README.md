# WordPress on Kubernetes - Complete Production Deployment

Production-ready WordPress deployment on Kubernetes with MySQL StatefulSet, NGINX Ingress Controller, and comprehensive monitoring using Prometheus and Grafana.

## Project Overview

This project demonstrates the complete migration of a WordPress application from Docker Compose to Kubernetes, implementing DevOps best practices for container orchestration, persistent storage, networking, security, and observability.

### Architecture

```
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
```

## Quick Start - Complete Deployment

### Prerequisites Check
```bash
# Verify prerequisites
minikube status
kubectl version --client
helm version
aws --version
```

### Deploy Everything
```bash
git clone git@github.com:Lirhen/K8s.git
cd K8s
./deployment-scripts/deploy-all.sh
```

### Verify Complete Deployment
```bash
# Check all services are running
kubectl get all --all-namespaces

# Specifically check each component
kubectl get pods -n wordpress
kubectl get pods -n monitoring
kubectl get pods -n ingress-nginx

# All pods should show "Running" status
```

### Access All Services
```bash
# Start all port-forwards
kubectl port-forward -n wordpress svc/wordpress-service 8080:80 --address=0.0.0.0 &
kubectl port-forward -n monitoring svc/monitoring-grafana 3000:80 --address=0.0.0.0 &
kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090 --address=0.0.0.0 &

# Get Grafana admin password
kubectl get secret -n monitoring monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 --decode
```

**Access URLs:**
- WordPress: `http://your-server-ip:8080`
- Grafana: `http://your-server-ip:3000` (admin + password from above)
- Prometheus: `http://your-server-ip:9090`

## Repository Structure

```
K8s/
├── services/
│   ├── wordpress/               # WordPress Application Components
│   │   ├── namespace.yaml       # WordPress namespace
│   │   ├── secret.yaml          # MySQL credentials (base64 encoded)
│   │   ├── mysql-pvc.yaml       # Persistent volume claim (2Gi)
│   │   ├── mysql-statefulset.yaml # MySQL database StatefulSet
│   │   ├── mysql-service.yaml   # MySQL internal service
│   │   ├── wordpress-deployment.yaml # WordPress app (2 replicas)
│   │   ├── wordpress-service.yaml # WordPress internal service
│   │   ├── wordpress-ingress.yaml # External access via NGINX
│   │   ├── create-ecr-secret.sh # AWS ECR authentication script
│   │   └── helm-chart/          # Helm chart version
│   │       ├── Chart.yaml       # Helm chart metadata
│   │       ├── values.yaml      # Default values
│   │       └── templates/       # Kubernetes templates
│   ├── ingress/                 # NGINX Ingress Controller
│   └── monitoring/              # Prometheus/Grafana monitoring
├── deployment-scripts/          # Automated deployment scripts
│   ├── 01-deploy-ingress.sh    # NGINX Ingress Controller setup
│   ├── 02-deploy-wordpress.sh  # WordPress + MySQL deployment
│   ├── 03-deploy-monitoring.sh # Monitoring stack deployment
│   └── deploy-all.sh           # Complete automated deployment
└── docs/                       # Additional documentation
    └── TROUBLESHOOTING.md      # Common issues and solutions
```

## Complete Service Stack

### WordPress Application
- **WordPress**: 2 replicas with rolling updates for high availability
- **MySQL**: StatefulSet with persistent 2Gi storage for data persistence
- **Storage**: PersistentVolumeClaim ensures data survives pod restarts
- **Security**: Kubernetes Secrets for database credentials
- **Images**: Private AWS ECR registry integration
- **Health Checks**: Readiness and liveness probes configured

### Networking and Access
- **Ingress Controller**: NGINX for external HTTP/HTTPS access
- **Services**: ClusterIP for internal pod-to-pod communication
- **DNS**: Kubernetes internal service discovery
- **Load Balancing**: Automatic load balancing across WordPress replicas

### Monitoring and Observability
- **Prometheus**: Metrics collection, storage, and alerting engine
- **Grafana**: Data visualization with custom dashboards
- **AlertManager**: Alert routing and notification management
- **Node Exporter**: System-level metrics collection
- **Kube State Metrics**: Kubernetes object metrics
- **Custom Panel**: WordPress container uptime monitoring

## Step-by-Step Manual Deployment

If you prefer to deploy components individually:

### 1. Deploy NGINX Ingress Controller
```bash
./deployment-scripts/01-deploy-ingress.sh
# Verify: kubectl get pods -n ingress-nginx
```

### 2. Deploy WordPress Application
```bash
./deployment-scripts/02-deploy-wordpress.sh
# Verify: kubectl get pods -n wordpress
```

### 3. Deploy Monitoring Stack
```bash
./deployment-scripts/03-deploy-monitoring.sh
# Verify: kubectl get pods -n monitoring
```

## Configuration Details

### Database Configuration
- MySQL 5.7 with persistent 2Gi storage
- Credentials securely stored in Kubernetes Secrets
- StatefulSet ensures stable network identity and ordered deployment
- Persistent volume survives pod restarts and reschedules

### WordPress Configuration  
- 2 replicas for high availability and load distribution
- Rolling update deployment strategy for zero-downtime updates
- Health checks: readiness probe (30s delay) and liveness probe (60s delay)
- Resource limits: 512Mi memory, 500m CPU per container
- Environment variables injected from Secrets

### Security Implementation
- Private AWS ECR registry for container images
- Kubernetes Secrets for sensitive data (database passwords)
- Service accounts with minimal required privileges
- Network policies ready for implementation
- Resource quotas and limits to prevent resource exhaustion

### Monitoring Configuration
- **Container Uptime Panel**: Custom Grafana panel using query:
  ```promql
  kube_pod_container_status_running{namespace="wordpress"}
  ```
- **Resource Monitoring**: CPU, memory, and storage metrics
- **Application Health**: HTTP response times and error rates
- **Database Metrics**: Connection counts and query performance

## Verification and Testing

### Complete System Check
```bash
# 1. Verify all namespaces exist
kubectl get ns

# 2. Check all pods are running
kubectl get pods --all-namespaces

# 3. Verify services are accessible
kubectl get svc --all-namespaces

# 4. Test WordPress accessibility
curl -I http://your-server-ip:8080

# 5. Verify Grafana dashboard
# Access Grafana UI and check "WordPress Container Uptime" panel

# 6. Check Prometheus targets
# Access Prometheus UI → Status → Targets (all should be "UP")
```

### Performance Testing
```bash
# Check resource usage
kubectl top pods -n wordpress
kubectl top nodes

# Verify persistent storage
kubectl get pvc -n wordpress
kubectl get pvc -n monitoring
```

## Production Readiness Features

### High Availability
- Multiple WordPress replicas (2) for load distribution
- StatefulSet for database ensures consistent identity
- Persistent storage prevents data loss
- Health checks enable automatic pod recovery
- Rolling updates ensure zero-downtime deployments

### Monitoring and Alerting
- Comprehensive metrics collection via Prometheus
- Visual monitoring dashboards in Grafana
- Container uptime tracking for reliability monitoring
- Resource utilization monitoring for capacity planning
- Alert rules ready for customization

### Security Best Practices
- No hardcoded secrets in configuration files
- Private container registry (AWS ECR) usage
- Kubernetes RBAC ready for fine-grained permissions
- Network policies framework in place
- Resource limits prevent resource exhaustion attacks

## Troubleshooting Guide

### WordPress Issues
```bash
# WordPress pods not starting
kubectl describe pod -n wordpress -l app=wordpress
kubectl logs -n wordpress -l app=wordpress

# Database connection issues  
kubectl logs -n wordpress mysql-0
kubectl get secret mysql-secret -n wordpress -o yaml
```

### Monitoring Issues
```bash
# Grafana not accessible
kubectl get pods -n monitoring | grep grafana
kubectl logs -n monitoring -l "app.kubernetes.io/name=grafana"

# Prometheus not collecting metrics
kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090
# Check http://localhost:9090/targets for target health
```

### Ingress Issues
```bash
# Ingress controller problems
kubectl get pods -n ingress-nginx
kubectl describe ingress wordpress-ingress -n wordpress
kubectl logs -n ingress-nginx -l app.kubernetes.io/component=controller
```

## Cleanup and Maintenance

### Complete Environment Cleanup
```bash
# Remove all deployed services
kubectl delete namespace wordpress
kubectl delete namespace monitoring
kubectl delete namespace ingress-nginx

# Verify cleanup
kubectl get all --all-namespaces
```

### Individual Service Management
```bash
# Remove only monitoring
helm uninstall monitoring -n monitoring
kubectl delete namespace monitoring

# Remove only ingress
helm uninstall my-release -n ingress-nginx
kubectl delete namespace ingress-nginx
```

## Migration Documentation

### From Docker Compose to Kubernetes

| Docker Compose Component | Kubernetes Equivalent | Purpose |
|--------------------------|----------------------|---------|
| `wordpress` service | Deployment + Service + Ingress | Application layer |
| `db` service | StatefulSet + Service + PVC | Database layer |
| `volumes` | PersistentVolumeClaim | Data persistence |
| `networks` | Kubernetes Services + DNS | Internal networking |
| Environment variables | Secrets + ConfigMaps | Configuration management |
| Port mappings | Services + Ingress | Traffic routing |

### Key Architectural Changes
- **State Management**: StatefulSet replaces simple container restart
- **Networking**: Kubernetes Services replace Docker networks  
- **Storage**: PersistentVolumes replace Docker volumes
- **Service Discovery**: Kubernetes DNS replaces container names
- **Load Balancing**: Kubernetes Services provide automatic load balancing
- **Health Checks**: Native Kubernetes probes replace Docker healthchecks

## Workshop Assignment Completion

This project fulfills all requirements from the Kubernetes Workshop assignment:

### ✅ Before Deployment
- Docker Compose understanding and analysis completed
- Container images pulled and pushed to AWS ECR
- Repository structure organized for production use

### ✅ Deployment Requirements  
1. **NGINX Ingress Controller**: Deployed and managing external access
2. **WordPress Application**: Deployment, Service, and Ingress configured
3. **Database Setup**: MySQL StatefulSet with PVC and Service
4. **Application Verification**: WordPress accessible and functional
5. **Monitoring Stack**: kube-prometheus-stack installed and operational
6. **Grafana Panel**: Custom panel monitoring WordPress container uptime

### ✅ Deliverables
- **Git Repository**: Complete with organized Kubernetes resources
- **Helm Integration**: Charts and automated deployment scripts
- **Documentation**: Comprehensive README with deployment instructions
- **Monitoring**: Production-ready observability stack

## License and Support

**License**: MIT License

**Support Resources**:
1. Review this documentation thoroughly
2. Check pod logs: `kubectl logs <pod-name> -n <namespace>`  
3. Inspect resources: `kubectl describe <resource-type> <name> -n <namespace>`
4. Monitor resource usage: `kubectl top pods -n <namespace>`

---

**Project Status**: Production Ready  
**Last Updated**: September 2025  
**Version**: 1.0  
**Author**: DevOps Kubernetes Workshop
