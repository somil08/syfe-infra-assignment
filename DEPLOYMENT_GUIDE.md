# Deployment Guide - WordPress on Kubernetes

**Author:** Somil Rathore  
**Institution:** Indian Institute of Information Technology, Bhopal

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Environment Setup](#environment-setup)
3. [Building Docker Images](#building-docker-images)
4. [Deploying WordPress Application](#deploying-wordpress-application)
5. [Deploying Monitoring Stack](#deploying-monitoring-stack)
6. [Accessing Applications](#accessing-applications)
7. [Testing and Verification](#testing-and-verification)
8. [Scaling](#scaling)
9. [Troubleshooting](#troubleshooting)
10. [Cleanup](#cleanup)

---

## Prerequisites

### Required Tools

- **Kubernetes Cluster** (v1.24 or higher)
  - Minikube (for local development)
  - Kind (Kubernetes in Docker)
  - Cloud provider (GKE, EKS, AKS)
- **kubectl** (v1.24+)
- **Helm** (v3.x)
- **Docker** (v20.10+)
- **Git**

### Verify Installation

```bash
# Check kubectl
kubectl version --client

# Check Helm
helm version

# Check Docker
docker --version

# Check Kubernetes cluster
kubectl cluster-info
```

---

## Environment Setup

### 1. Start Kubernetes Cluster (Minikube Example)

```bash
# Start Minikube with sufficient resources
minikube start --cpus=4 --memory=8192 --disk-size=20g

# Enable required addons
minikube addons enable metrics-server
minikube addons enable storage-provisioner

# Verify cluster is running
kubectl get nodes
```

### 2. Configure kubectl Context

```bash
# View contexts
kubectl config get-contexts

# Use the correct context
kubectl config use-context minikube
```

### 3. Create Namespace (Optional)

```bash
# Create dedicated namespace
kubectl create namespace wordpress

# Set as default
kubectl config set-context --current --namespace=wordpress
```

---

## Building Docker Images

### 1. Navigate to Project Directory

```bash
cd "C:\Signet\RnD\Extra work - not project"
```

### 2. Build Nginx (OpenResty) Image

```bash
# Build the image
docker build -t wordpress-nginx:latest ./docker/nginx

# Verify the build
docker images | grep wordpress-nginx

# Test the image (optional)
docker run --rm wordpress-nginx:latest nginx -v
```

**Note:** The OpenResty build includes:
- Lua support
- PostgreSQL module
- Iconv module
- PCR JIT
- IPv6 support

### 3. Build WordPress Image

```bash
# Build the image
docker build -t wordpress-custom:latest ./docker/wordpress

# Verify the build
docker images | grep wordpress-custom

# Test PHP version (optional)
docker run --rm wordpress-custom:latest php -v
```

### 4. Build MySQL Image

```bash
# Build the image
docker build -t mysql-custom:latest ./docker/mysql

# Verify the build
docker images | grep mysql-custom

# Test MySQL version (optional)
docker run --rm mysql-custom:latest mysqld --version
```

### 5. Load Images to Minikube (If Using Minikube)

```bash
# Load images to Minikube's Docker daemon
minikube image load wordpress-nginx:latest
minikube image load wordpress-custom:latest
minikube image load mysql-custom:latest

# Verify images are loaded
minikube image ls | grep wordpress
```

### 6. Push to Registry (For Production)

```bash
# Tag images for your registry
docker tag wordpress-nginx:latest your-registry.com/wordpress-nginx:latest
docker tag wordpress-custom:latest your-registry.com/wordpress-custom:latest
docker tag mysql-custom:latest your-registry.com/mysql-custom:latest

# Push to registry
docker push your-registry.com/wordpress-nginx:latest
docker push your-registry.com/wordpress-custom:latest
docker push your-registry.com/mysql-custom:latest
```

---

## Deploying WordPress Application

### 1. Review Configuration

```bash
# View default values
cat helm-charts/wordpress-app/values.yaml

# Edit if needed (optional)
nano helm-charts/wordpress-app/values.yaml
```

**Key configurations to review:**
- Storage class (default: `standard`)
- Resource limits
- Replica counts
- Database credentials (⚠️ Change in production!)

### 2. Install WordPress Helm Chart

```bash
# Install the chart
helm install my-release ./helm-charts/wordpress-app

# Or with custom values
helm install my-release ./helm-charts/wordpress-app \
  --set mysql.env.MYSQL_ROOT_PASSWORD=SecurePassword123 \
  --set mysql.env.MYSQL_PASSWORD=WordPressPass123
```

### 3. Verify Deployment

```bash
# Check all resources
kubectl get all

# Check pods status
kubectl get pods -w

# Check persistent volumes
kubectl get pv,pvc

# Check services
kubectl get svc
```

**Expected output:**
```
NAME                                    READY   STATUS    RESTARTS   AGE
pod/my-release-wordpress-app-mysql-xxx  1/1     Running   0          2m
pod/my-release-wordpress-app-wordpress-xxx  1/1     Running   0          2m
pod/my-release-wordpress-app-nginx-xxx  1/1     Running   0          2m
```

### 4. Check Logs

```bash
# MySQL logs
kubectl logs -l component=mysql --tail=50

# WordPress logs
kubectl logs -l component=wordpress --tail=50

# Nginx logs
kubectl logs -l component=nginx --tail=50
```

### 5. Verify Storage

```bash
# Check PV status
kubectl get pv

# Check PVC status
kubectl get pvc

# Describe PVC for details
kubectl describe pvc my-release-wordpress-app-wordpress-pvc
kubectl describe pvc my-release-wordpress-app-mysql-pvc
```

---

## Deploying Monitoring Stack

### 1. Add Helm Repositories

```bash
# Add Prometheus repository
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Add Grafana repository
helm repo add grafana https://grafana.github.io/helm-charts

# Update repositories
helm repo update
```

### 2. Update Dependencies

```bash
# Navigate to monitoring chart
cd helm-charts/monitoring

# Update dependencies
helm dependency update

# Verify dependencies
helm dependency list
```

### 3. Install Monitoring Stack

```bash
# Install from project root
cd ../..

# Install monitoring
helm install monitoring ./helm-charts/monitoring

# Or with custom values
helm install monitoring ./helm-charts/monitoring \
  --set grafana.adminPassword=SecureGrafanaPass123
```

### 4. Verify Monitoring Deployment

```bash
# Check monitoring pods
kubectl get pods -l "app.kubernetes.io/name in (prometheus,grafana)"

# Check services
kubectl get svc -l "app.kubernetes.io/name in (prometheus,grafana)"

# Wait for all pods to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus --timeout=300s
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana --timeout=300s
```

---

## Accessing Applications

### 1. Access WordPress

#### Option A: Port Forward (Development)

```bash
# Port forward to Nginx service
kubectl port-forward svc/nginx-service 8080:80

# Access in browser: http://localhost:8080
```

#### Option B: LoadBalancer (Cloud)

```bash
# Get external IP
kubectl get svc nginx-service

# Access using the EXTERNAL-IP
```

#### Option C: Minikube Service

```bash
# Open in browser automatically
minikube service nginx-service
```

### 2. Access Grafana

#### Get Admin Password

```bash
# Get Grafana password
kubectl get secret monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 --decode
echo
```

#### Access Grafana UI

```bash
# Port forward
kubectl port-forward svc/monitoring-grafana 3000:80

# Access in browser: http://localhost:3000
# Username: admin
# Password: (from above command or values.yaml)
```

### 3. Access Prometheus

```bash
# Port forward
kubectl port-forward svc/monitoring-prometheus-server 9090:80

# Access in browser: http://localhost:9090
```

### 4. Access Nginx Metrics

```bash
# Port forward metrics endpoint
kubectl port-forward svc/nginx-service 9145:9145

# View metrics: http://localhost:9145/metrics
```

---

## Testing and Verification

### 1. Test WordPress Installation

```bash
# Check WordPress is responding
curl -I http://localhost:8080

# Should return HTTP 200 OK
```

### 2. Test Database Connection

```bash
# Connect to MySQL pod
kubectl exec -it $(kubectl get pod -l component=mysql -o jsonpath='{.items[0].metadata.name}') -- mysql -u wordpress -pwordpress123 wordpress

# Run test query
mysql> SHOW TABLES;
mysql> SELECT * FROM health_check;
mysql> exit
```

### 3. Test Nginx Metrics

```bash
# Fetch metrics
curl http://localhost:9145/metrics

# Should show Prometheus format metrics
```

### 4. Test Prometheus Targets

```bash
# Open Prometheus UI
# Navigate to Status > Targets
# Verify all targets are UP
```

### 5. Test Grafana Dashboards

```bash
# Login to Grafana
# Navigate to Dashboards
# Open "Kubernetes Cluster" dashboard
# Verify metrics are displaying
```

---

## Scaling

### 1. Scale WordPress Pods

```bash
# Scale WordPress deployment
kubectl scale deployment my-release-wordpress-app-wordpress --replicas=3

# Verify scaling
kubectl get pods -l component=wordpress
```

### 2. Scale Nginx Pods

```bash
# Scale Nginx deployment
kubectl scale deployment my-release-wordpress-app-nginx --replicas=3

# Verify scaling
kubectl get pods -l component=nginx
```

### 3. Enable Horizontal Pod Autoscaling

```bash
# Create HPA for WordPress
kubectl autoscale deployment my-release-wordpress-app-wordpress \
  --cpu-percent=80 \
  --min=2 \
  --max=5

# Create HPA for Nginx
kubectl autoscale deployment my-release-wordpress-app-nginx \
  --cpu-percent=80 \
  --min=2 \
  --max=5

# Check HPA status
kubectl get hpa
```

---

## Troubleshooting

### Common Issues

#### 1. Pods Not Starting

```bash
# Check pod status
kubectl get pods

# Describe pod for events
kubectl describe pod <pod-name>

# Check logs
kubectl logs <pod-name>
```

#### 2. Image Pull Errors

```bash
# If using Minikube, ensure images are loaded
minikube image ls

# Reload images if needed
minikube image load wordpress-nginx:latest
```

#### 3. Storage Issues

```bash
# Check PV/PVC status
kubectl get pv,pvc

# Describe for details
kubectl describe pvc <pvc-name>

# For Minikube, ensure storage provisioner is enabled
minikube addons enable storage-provisioner
```

#### 4. Service Not Accessible

```bash
# Check service endpoints
kubectl get endpoints

# Check service details
kubectl describe svc nginx-service

# Test internal connectivity
kubectl run test-pod --image=busybox -it --rm -- wget -O- http://nginx-service
```

#### 5. Monitoring Not Working

```bash
# Check Prometheus targets
kubectl port-forward svc/monitoring-prometheus-server 9090:80
# Visit: http://localhost:9090/targets

# Check ServiceMonitor
kubectl get servicemonitor

# Check Prometheus logs
kubectl logs -l app.kubernetes.io/name=prometheus
```

---

## Cleanup

### 1. Delete WordPress Application

```bash
# Uninstall Helm release
helm delete my-release

# Verify deletion
kubectl get all
```

### 2. Delete Monitoring Stack

```bash
# Uninstall monitoring
helm delete monitoring

# Verify deletion
kubectl get all -l "app.kubernetes.io/name in (prometheus,grafana)"
```

### 3. Delete Persistent Volumes

```bash
# Delete PVCs (this will delete data!)
kubectl delete pvc --all

# Delete PVs
kubectl delete pv --all
```

### 4. Delete Namespace (If Created)

```bash
# Delete namespace and all resources
kubectl delete namespace wordpress
```

### 5. Stop Minikube (If Using)

```bash
# Stop Minikube
minikube stop

# Delete Minikube cluster (optional)
minikube delete
```

---

## Production Considerations

### Security

1. **Change default passwords** in `values.yaml`
2. **Use Kubernetes Secrets** for sensitive data
3. **Enable TLS/SSL** for external access
4. **Implement Network Policies**
5. **Use RBAC** for access control

### High Availability

1. **Multiple replicas** for all components
2. **Pod Disruption Budgets**
3. **Anti-affinity rules** for pod distribution
4. **ReadWriteMany storage** for shared data

### Backup

1. **Regular database backups**
2. **Persistent volume snapshots**
3. **Disaster recovery plan**

### Monitoring

1. **Set up alerting** (email, Slack, PagerDuty)
2. **Custom dashboards** for business metrics
3. **Log aggregation** (ELK, Loki)

---

## Next Steps

1. ✅ Complete WordPress setup through web UI
2. ✅ Configure Grafana dashboards
3. ✅ Set up alerting rules
4. ✅ Implement backup strategy
5. ✅ Configure domain and SSL
6. ✅ Performance testing
7. ✅ Security hardening

---

**For questions or issues, refer to:**
- [METRICS_DOCUMENTATION.md](./METRICS_DOCUMENTATION.md)
- [README.md](./README.md)
- Kubernetes documentation: https://kubernetes.io/docs/
- Helm documentation: https://helm.sh/docs/
