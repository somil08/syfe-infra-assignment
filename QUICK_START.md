# Quick Start Guide - WordPress on Kubernetes

**Author:** Somil Rathore  
**For:** Syfe Company - First Round Internship Task

## 🚀 5-Minute Setup (Minikube)

### Prerequisites Check

```bash
# Verify installations
kubectl version --client
helm version
docker --version
minikube version
```

### Step 1: Start Cluster

```bash
# Start Minikube
minikube start --cpus=4 --memory=8192

# Enable addons
minikube addons enable metrics-server
```

### Step 2: Build Images

```bash
# Navigate to project
cd "C:\Signet\RnD\Extra work - not project"

# Build all images
docker build -t wordpress-nginx:latest ./docker/nginx
docker build -t wordpress-custom:latest ./docker/wordpress
docker build -t mysql-custom:latest ./docker/mysql

# Load to Minikube
minikube image load wordpress-nginx:latest
minikube image load wordpress-custom:latest
minikube image load mysql-custom:latest
```

### Step 3: Deploy WordPress

```bash
# Install WordPress application
helm install my-release ./helm-charts/wordpress-app

# Wait for pods to be ready (2-3 minutes)
kubectl get pods -w
```

### Step 4: Deploy Monitoring

```bash
# Add Helm repos
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Update dependencies
cd helm-charts/monitoring
helm dependency update
cd ../..

# Install monitoring
helm install monitoring ./helm-charts/monitoring

# Wait for monitoring pods (2-3 minutes)
kubectl get pods -l "app.kubernetes.io/name in (prometheus,grafana)" -w
```

### Step 5: Access Applications

```bash
# Terminal 1: WordPress
kubectl port-forward svc/nginx-service 8080:80
# Visit: http://localhost:8080

# Terminal 2: Grafana
kubectl port-forward svc/monitoring-grafana 3000:80
# Visit: http://localhost:3000
# Username: admin
# Password: admin123

# Terminal 3: Prometheus
kubectl port-forward svc/monitoring-prometheus-server 9090:80
# Visit: http://localhost:9090
```

## 📊 Verify Monitoring

### Check Nginx Metrics

```bash
# Port forward metrics
kubectl port-forward svc/nginx-service 9145:9145

# View metrics in browser
# http://localhost:9145/metrics
```

### Check Prometheus Targets

1. Open Prometheus: http://localhost:9090
2. Go to Status > Targets
3. Verify all targets are "UP"

### Check Grafana Dashboards

1. Login to Grafana: http://localhost:3000
2. Go to Dashboards
3. Import dashboards:
   - Kubernetes Cluster (ID: 7249)
   - Nginx Metrics (ID: 12708)
   - Pod Metrics (ID: 6417)

## 🧪 Test the Setup

### Test 1: WordPress is Running

```bash
curl -I http://localhost:8080
# Should return: HTTP/1.1 200 OK
```

### Test 2: Generate Traffic

```bash
# Generate some requests
for i in {1..100}; do curl -s http://localhost:8080 > /dev/null; done
```

### Test 3: Check Metrics

```bash
# Check request count increased
curl http://localhost:9145/metrics | grep nginx_http_requests_total
```

### Test 4: Verify Alerts

1. Open Prometheus: http://localhost:9090/alerts
2. Check configured alerts
3. All should be "Inactive" (green)

## 🧹 Cleanup

```bash
# Delete everything
helm delete my-release
helm delete monitoring

# Delete PVCs
kubectl delete pvc --all

# Stop Minikube
minikube stop
```

## 📖 Full Documentation

- **[README.md](./README.md)** - Project overview
- **[DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)** - Detailed deployment
- **[METRICS_DOCUMENTATION.md](./METRICS_DOCUMENTATION.md)** - All metrics

## 🆘 Troubleshooting

### Pods Not Starting?

```bash
# Check pod status
kubectl get pods

# Check logs
kubectl logs <pod-name>

# Describe pod
kubectl describe pod <pod-name>
```

### Can't Access Services?

```bash
# Check services
kubectl get svc

# Check endpoints
kubectl get endpoints

# Restart port-forward
kubectl port-forward svc/nginx-service 8080:80
```

### Images Not Found?

```bash
# Verify images in Minikube
minikube image ls | grep wordpress

# Reload if needed
minikube image load wordpress-nginx:latest
```

## ✅ Task Completion Checklist

- [x] OpenResty Nginx with Lua compiled
- [x] Custom WordPress and MySQL Dockerfiles
- [x] PersistentVolumes with ReadWriteMany
- [x] Helm charts for deployment
- [x] Prometheus/Grafana monitoring
- [x] Pod CPU utilization monitoring
- [x] Nginx request count tracking
- [x] Nginx 5xx error tracking
- [x] Comprehensive documentation
- [x] Easy deployment and cleanup

## 🎯 Success Criteria

✅ WordPress accessible at http://localhost:8080  
✅ Grafana accessible at http://localhost:3000  
✅ Prometheus accessible at http://localhost:9090  
✅ Nginx metrics at http://localhost:9145/metrics  
✅ All pods in "Running" state  
✅ All Prometheus targets "UP"  
✅ Grafana dashboards showing data  

---

**Good luck with your Syfe internship! 🚀**
