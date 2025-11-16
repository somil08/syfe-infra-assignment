# Project Index - WordPress on Kubernetes

**Quick Navigation Guide**

---

## 📚 Documentation Files

### Getting Started
- **[README.md](./README.md)** - Main project overview and quick start
- **[QUICK_START.md](./QUICK_START.md)** - 5-minute setup guide for rapid deployment
- **[DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)** - Comprehensive step-by-step deployment instructions

### Reference Documentation
- **[METRICS_DOCUMENTATION.md](./METRICS_DOCUMENTATION.md)** - Complete metrics reference with PromQL queries
- **[TROUBLESHOOTING.md](./TROUBLESHOOTING.md)** - Common issues and solutions
- **[PROJECT_SUMMARY.md](./PROJECT_SUMMARY.md)** - Executive summary and technical highlights
- **[TASK_CHECKLIST.md](./TASK_CHECKLIST.md)** - Task requirements verification
- **[PRESENTATION_NOTES.md](./PRESENTATION_NOTES.md)** - Demo script and talking points

---

## 🐳 Docker Images

### Nginx (OpenResty)
- **[docker/nginx/Dockerfile](./docker/nginx/Dockerfile)** - OpenResty with Lua support
- **[docker/nginx/nginx.conf](./docker/nginx/nginx.conf)** - Main Nginx configuration
- **[docker/nginx/wordpress.conf](./docker/nginx/wordpress.conf)** - WordPress virtual host
- **[docker/nginx/lua/metrics.lua](./docker/nginx/lua/metrics.lua)** - Prometheus metrics exporter
- **[docker/nginx/lua/request_logger.lua](./docker/nginx/lua/request_logger.lua)** - Request tracking

### WordPress
- **[docker/wordpress/Dockerfile](./docker/wordpress/Dockerfile)** - WordPress with PHP-FPM
- **[docker/wordpress/wp-config-docker.php](./docker/wordpress/wp-config-docker.php)** - WordPress configuration

### MySQL
- **[docker/mysql/Dockerfile](./docker/mysql/Dockerfile)** - MySQL 8.0
- **[docker/mysql/my.cnf](./docker/mysql/my.cnf)** - MySQL configuration
- **[docker/mysql/init-wordpress.sql](./docker/mysql/init-wordpress.sql)** - Database initialization

---

## ⎈ Kubernetes & Helm

### WordPress Application Chart
- **[helm-charts/wordpress-app/Chart.yaml](./helm-charts/wordpress-app/Chart.yaml)** - Chart metadata
- **[helm-charts/wordpress-app/values.yaml](./helm-charts/wordpress-app/values.yaml)** - Configuration values
- **[helm-charts/wordpress-app/templates/_helpers.tpl](./helm-charts/wordpress-app/templates/_helpers.tpl)** - Template helpers
- **[helm-charts/wordpress-app/templates/pv.yaml](./helm-charts/wordpress-app/templates/pv.yaml)** - PersistentVolumes
- **[helm-charts/wordpress-app/templates/pvc.yaml](./helm-charts/wordpress-app/templates/pvc.yaml)** - PersistentVolumeClaims
- **[helm-charts/wordpress-app/templates/mysql-deployment.yaml](./helm-charts/wordpress-app/templates/mysql-deployment.yaml)** - MySQL deployment
- **[helm-charts/wordpress-app/templates/wordpress-deployment.yaml](./helm-charts/wordpress-app/templates/wordpress-deployment.yaml)** - WordPress deployment
- **[helm-charts/wordpress-app/templates/nginx-deployment.yaml](./helm-charts/wordpress-app/templates/nginx-deployment.yaml)** - Nginx deployment
- **[helm-charts/wordpress-app/templates/services.yaml](./helm-charts/wordpress-app/templates/services.yaml)** - Kubernetes services
- **[helm-charts/wordpress-app/templates/servicemonitor.yaml](./helm-charts/wordpress-app/templates/servicemonitor.yaml)** - Prometheus ServiceMonitor

### Monitoring Stack Chart
- **[helm-charts/monitoring/Chart.yaml](./helm-charts/monitoring/Chart.yaml)** - Monitoring chart metadata
- **[helm-charts/monitoring/values.yaml](./helm-charts/monitoring/values.yaml)** - Prometheus & Grafana configuration

---

## 🔧 Automation Scripts

### Linux/Mac Scripts
- **[scripts/build-images.sh](./scripts/build-images.sh)** - Build all Docker images
- **[scripts/deploy.sh](./scripts/deploy.sh)** - Deploy WordPress and monitoring
- **[scripts/cleanup.sh](./scripts/cleanup.sh)** - Clean up all resources
- **[scripts/test-deployment.sh](./scripts/test-deployment.sh)** - Test deployment

### Windows Scripts
- **[scripts/build-images.bat](./scripts/build-images.bat)** - Build all Docker images (Windows)
- **[scripts/deploy.bat](./scripts/deploy.bat)** - Deploy WordPress and monitoring (Windows)
- **[scripts/cleanup.bat](./scripts/cleanup.bat)** - Clean up all resources (Windows)

---

## 📖 How to Use This Project

### For First-Time Setup
1. Read **[README.md](./README.md)** for project overview
2. Follow **[QUICK_START.md](./QUICK_START.md)** for rapid deployment
3. Refer to **[DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)** for detailed steps

### For Understanding Metrics
1. Read **[METRICS_DOCUMENTATION.md](./METRICS_DOCUMENTATION.md)** for all metrics
2. Check Prometheus queries and alert rules
3. Review Grafana dashboard configurations

### For Troubleshooting
1. Check **[TROUBLESHOOTING.md](./TROUBLESHOOTING.md)** for common issues
2. Review pod logs: `kubectl logs <pod-name>`
3. Check events: `kubectl get events --sort-by='.lastTimestamp'`

### For Presentation/Demo
1. Review **[PRESENTATION_NOTES.md](./PRESENTATION_NOTES.md)** for demo script
2. Check **[PROJECT_SUMMARY.md](./PROJECT_SUMMARY.md)** for highlights
3. Verify **[TASK_CHECKLIST.md](./TASK_CHECKLIST.md)** for completeness

---

## 🎯 Quick Commands Reference

### Build Images
```bash
# Linux/Mac
./scripts/build-images.sh

# Windows
scripts\build-images.bat
```

### Deploy Everything
```bash
# Linux/Mac
./scripts/deploy.sh

# Windows
scripts\deploy.bat
```

### Access Applications
```bash
# WordPress
kubectl port-forward svc/nginx-service 8080:80
# http://localhost:8080

# Grafana
kubectl port-forward svc/monitoring-grafana 3000:80
# http://localhost:3000

# Prometheus
kubectl port-forward svc/monitoring-prometheus-server 9090:80
# http://localhost:9090

# Nginx Metrics
kubectl port-forward svc/nginx-service 9145:9145
# http://localhost:9145/metrics
```

### Cleanup
```bash
# Linux/Mac
./scripts/cleanup.sh

# Windows
scripts\cleanup.bat
```

---

## 📊 Key Metrics Endpoints

| Component | Endpoint | Port | Path |
|-----------|----------|------|------|
| Nginx Metrics | nginx-service | 9145 | /metrics |
| Nginx Health | nginx-service | 80 | /health |
| Nginx Status | nginx-service | 80 | /nginx_status |
| Prometheus | monitoring-prometheus-server | 80 | / |
| Grafana | monitoring-grafana | 80 | / |
| WordPress | nginx-service | 80 | / |

---

## 🔍 File Categories

### Configuration Files
- `values.yaml` files - Helm chart configurations
- `*.conf` files - Nginx configurations
- `my.cnf` - MySQL configuration
- `wp-config-docker.php` - WordPress configuration

### Deployment Files
- `Dockerfile` files - Container image definitions
- `*.yaml` in templates/ - Kubernetes manifests
- `Chart.yaml` files - Helm chart metadata

### Documentation Files
- `*.md` files - Markdown documentation
- All located in project root

### Script Files
- `*.sh` files - Linux/Mac automation scripts
- `*.bat` files - Windows automation scripts
- All located in scripts/

---

## 🎓 Learning Resources

### Understanding the Stack
1. **Kubernetes Basics** - [kubernetes.io/docs](https://kubernetes.io/docs/)
2. **Helm Charts** - [helm.sh/docs](https://helm.sh/docs/)
3. **OpenResty** - [openresty.org](https://openresty.org/)
4. **Prometheus** - [prometheus.io/docs](https://prometheus.io/docs/)
5. **Grafana** - [grafana.com/docs](https://grafana.com/docs/)

### Project-Specific Learning
1. **PersistentVolumes** - See [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md#verify-storage)
2. **Lua Metrics** - See [docker/nginx/lua/metrics.lua](./docker/nginx/lua/metrics.lua)
3. **Helm Templates** - See [helm-charts/wordpress-app/templates/](./helm-charts/wordpress-app/templates/)
4. **PromQL Queries** - See [METRICS_DOCUMENTATION.md](./METRICS_DOCUMENTATION.md)

---

## ✅ Project Status

### Completed Features
- ✅ Custom Docker images (Nginx, WordPress, MySQL)
- ✅ OpenResty with Lua support
- ✅ PersistentVolumes with ReadWriteMany
- ✅ Helm charts for deployment
- ✅ Prometheus/Grafana monitoring
- ✅ Pod CPU utilization tracking
- ✅ Nginx request count and 5xx errors
- ✅ Comprehensive documentation
- ✅ Automation scripts
- ✅ Testing scripts

### Production-Ready Features
- ✅ Health checks (liveness & readiness)
- ✅ Resource limits and requests
- ✅ Security best practices
- ✅ Horizontal scaling support
- ✅ Monitoring and alerting
- ✅ Comprehensive logging

---

## 🤝 Contributing

This project is complete and ready for submission. For improvements or suggestions:
1. Review the code
2. Test thoroughly
3. Document changes
4. Follow existing patterns

---

## 📞 Support

For questions or issues:
1. Check **[TROUBLESHOOTING.md](./TROUBLESHOOTING.md)**
2. Review **[DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)**
3. Check Kubernetes/Helm documentation
4. Review pod logs and events

---

## 📝 License

This project is created for educational purposes as part of Syfe company's internship selection process.

---

**Author:** Somil Rathore  
**Institution:** Indian Institute of Information Technology, Bhopal  
**Purpose:** Syfe First Round Internship Task  
**Date:** November 2024

---

**Quick Links:**
- [Main README](./README.md)
- [Quick Start](./QUICK_START.md)
- [Deployment Guide](./DEPLOYMENT_GUIDE.md)
- [Metrics Documentation](./METRICS_DOCUMENTATION.md)
- [Troubleshooting](./TROUBLESHOOTING.md)
