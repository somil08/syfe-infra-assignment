# Production-Grade WordPress on Kubernetes

**Author:** Somil Rathore  
**Institution:** Indian Institute of Information Technology, Bhopal  
**Company:** Syfe - First Round Internship Task

## 📋 Project Overview

This project demonstrates a production-grade WordPress deployment on Kubernetes with comprehensive monitoring and alerting using Prometheus and Grafana.

## 🏗️ Architecture

```
┌─────────────┐
│   Client    │
└──────┬──────┘
       │
       ▼
┌─────────────────┐
│  Nginx (OpenResty)│  ← Reverse Proxy with Lua
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│   WordPress     │  ← PHP Application
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│     MySQL       │  ← Database
└─────────────────┘

Monitoring Stack:
┌─────────────────┐
│   Prometheus    │  ← Metrics Collection
└──────┬──────────┘
       │
       ▼
┌─────────────────┐
│    Grafana      │  ← Visualization & Alerting
└─────────────────┘
```

## 📁 Project Structure

```
.
├── README.md                          # This file
├── DEPLOYMENT_GUIDE.md                # Detailed deployment instructions
├── METRICS_DOCUMENTATION.md           # Required metrics documentation
├── docker/                            # Docker images
│   ├── nginx/
│   │   └── Dockerfile                 # OpenResty with Lua
│   ├── wordpress/
│   │   └── Dockerfile                 # WordPress with PHP-FPM
│   └── mysql/
│       └── Dockerfile                 # MySQL 8.0
├── helm-charts/                       # Helm charts
│   ├── wordpress-app/                 # WordPress application chart
│   │   ├── Chart.yaml
│   │   ├── values.yaml
│   │   └── templates/
│   │       ├── pv.yaml
│   │       ├── pvc.yaml
│   │       ├── mysql-deployment.yaml
│   │       ├── wordpress-deployment.yaml
│   │       ├── nginx-deployment.yaml
│   │       ├── services.yaml
│   │       └── configmaps.yaml
│   └── monitoring/                    # Monitoring stack chart
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── prometheus/
│           └── grafana/
└── kubernetes/                        # Raw Kubernetes manifests (reference)
    ├── storage/
    ├── mysql/
    ├── wordpress/
    └── nginx/
```

## 🚀 Quick Start

### Prerequisites

- Kubernetes cluster (v1.24+) - Minikube, Kind, or cloud provider
- kubectl configured
- Helm 3.x installed
- Docker (for building images)

### Step 1: Clone and Navigate

```bash
cd "C:\Signet\RnD\Extra work - not project"
```

### Step 2: Build Docker Images

```bash
# Build Nginx with OpenResty
docker build -t wordpress-nginx:latest ./docker/nginx

# Build WordPress
docker build -t wordpress-custom:latest ./docker/wordpress

# Build MySQL
docker build -t mysql-custom:latest ./docker/mysql
```

### Step 3: Deploy WordPress Application

```bash
# Install WordPress application
helm install my-release ./helm-charts/wordpress-app

# Verify deployment
kubectl get pods
kubectl get pvc
kubectl get svc
```

### Step 4: Deploy Monitoring Stack

```bash
# Install Prometheus and Grafana
helm install monitoring ./helm-charts/monitoring

# Get Grafana password
kubectl get secret monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 --decode

# Port forward to access Grafana
kubectl port-forward svc/monitoring-grafana 3000:80
```

### Step 5: Access Applications

```bash
# WordPress
kubectl port-forward svc/nginx-service 8080:80
# Visit: http://localhost:8080

# Grafana
kubectl port-forward svc/monitoring-grafana 3000:80
# Visit: http://localhost:3000 (admin/password from step 4)

# Prometheus
kubectl port-forward svc/monitoring-prometheus-server 9090:80
# Visit: http://localhost:9090
```

## 🧹 Cleanup

```bash
# Delete WordPress application
helm delete my-release

# Delete monitoring stack
helm delete monitoring

# Verify cleanup
kubectl get all
kubectl get pvc
kubectl get pv
```

## 📊 Monitoring Features

### Metrics Collected

1. **Container Metrics**
   - Pod CPU utilization
   - Pod Memory utilization
   - Container restart count

2. **Nginx Metrics**
   - Total request count
   - Total 5xx errors
   - Request rate
   - Response time

3. **WordPress Metrics**
   - PHP-FPM status
   - Application response time

4. **MySQL Metrics**
   - Query performance
   - Connection count
   - Database size

### Alerts Configured

- High CPU usage (>80%)
- High memory usage (>80%)
- High 5xx error rate
- Pod restart alerts
- Service down alerts

## 📖 Documentation

- **[DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)** - Detailed deployment steps
- **[METRICS_DOCUMENTATION.md](./METRICS_DOCUMENTATION.md)** - Complete metrics documentation

## 🔧 Customization

Edit `helm-charts/wordpress-app/values.yaml` to customize:
- Resource limits
- Storage sizes
- Replica counts
- Environment variables

Edit `helm-charts/monitoring/values.yaml` to customize:
- Alert thresholds
- Retention periods
- Grafana dashboards

## 🎯 Task Completion Checklist

- ✅ PersistentVolumes and PersistentVolumeClaims with ReadWriteMany
- ✅ Custom Dockerfiles for WordPress, MySQL, and Nginx
- ✅ OpenResty compiled with specified configure options
- ✅ Nginx reverse proxy to WordPress
- ✅ Helm charts for easy deployment
- ✅ Prometheus/Grafana monitoring stack
- ✅ Pod CPU utilization monitoring
- ✅ Nginx request count and 5xx error monitoring
- ✅ Comprehensive metrics documentation
- ✅ Clean deployment and cleanup procedures
- ✅ Best practices and documentation

## 🤝 Contact

**Somil Rathore**  
Final Year Student  
Indian Institute of Information Technology, Bhopal

---

**Note:** This project follows Kubernetes and Docker best practices with production-grade configurations suitable for real-world deployments.
