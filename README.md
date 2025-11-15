🏗️ WordPress Production Deployment on Kubernetes

Enterprise-Grade, Scalable, Secure & Monitored WordPress Setup

This repository contains a fully production-ready Kubernetes deployment of WordPress designed for high availability, horizontal scaling, enterprise performance, and deep observability (Prometheus + Grafana).

It includes a custom OpenResty/Nginx + Lua layer for advanced routing/security and an optimized MySQL StatefulSet.

🚀 Key Capabilities
Category	Features
Scalability	Horizontal Pod Autoscaler (3–10 replicas), RWX volumes, load-balanced architecture
Performance	OpenResty + Lua, PHP-FPM optimizations, Redis-ready WordPress
Reliability	Stateful MySQL, auto-recovery, persistent volumes
Monitoring	Kube-Prometheus, 50+ metrics, Grafana dashboards
Security	Rate limiting, custom Lua filters, hardened configs
Storage	ReadWriteMany storage (NFS/CephFS) for pod scaling
Automation	Helm-based deployment & upgrades
📦 Architecture
                           ┌─────────────────────────────────────┐
                           │     Load Balancer / Ingress         │
                           └─────────────────────────────────────┘
                                         │
                    ┌────────────────────┴────────────────────┐
                    │                                         │
         ┌──────────▼──────────┐                 ┌────────────▼──────────┐
         │    Nginx Pod #1     │                 │    Nginx Pod #N       │
         │  (OpenResty + Lua)  │                 │  (OpenResty + Lua)    │
         └──────────┬──────────┘                 └────────────┬──────────┘
                    │                                         │
         ┌──────────▼──────────┐                 ┌────────────▼──────────┐
         │ WordPress PHP-FPM   │                 │ WordPress PHP-FPM     │
         └──────────┬──────────┘                 └────────────┬──────────┘
                    └────────────────────┬─────────────────────┘
                                         │
                               ┌─────────▼────────┐
                               │  MySQL StatefulSet│
                               └───────────────────┘

🛠️ Prerequisites
Required Tools
Tool	Version	Purpose
Kubernetes	1.24+	Deployment environment
Helm	3.x	Package management
Docker	20.10+	Build images
kubectl	1.24+	Kubernetes CLI
Cluster Requirements

4+ vCPU, 8GB RAM

RWX Storage Class — NFS, CephFS, EFS, GlusterFS

LoadBalancer supported (or MetalLB)

⚡ Quick Start
1️⃣ Clone Repository
git clone https://github.com/yourusername/wordpress-k8s-production.git
cd wordpress-k8s-production

2️⃣ Build & Push Images
docker build -t your/openresty:latest docker/nginx
docker build -t your/wordpress:latest docker/wordpress
docker build -t your/mysql:8.0 docker/mysql

3️⃣ Configure Values
cp helm/wordpress/values.example.yaml helm/wordpress/values.yaml


Modify:

image registry

database credentials

storage class

autoscaling settings

4️⃣ Deploy WordPress
helm install my-wordpress ./helm/wordpress \
  --namespace wordpress \
  --create-namespace

5️⃣ Deploy Monitoring Stack
helm install prom prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace \
  -f monitoring/prometheus-values.yaml

6️⃣ Access Services
kubectl get svc -n wordpress
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80

📁 Repository Structure
.
├── docker/
│   ├── nginx/        # OpenResty + Lua
│   ├── wordpress/    # PHP-FPM WordPress
│   └── mysql/        # MySQL optimized image
│
├── helm/
│   └── wordpress/    # Main Helm chart
│
├── monitoring/
│   ├── prometheus-values.yaml
│   └── prometheus-rules.yaml
│
└── README.md

🔧 Custom Components
1. OpenResty / Nginx

Lua rate limiting

Security headers

Custom routing

Prometheus metrics endpoint

Example:

access_by_lua_block {
    local limit = require "resty.limit.req"
    local lim = limit.new("request_counters", 10, 5)
}

2. WordPress (PHP-FPM)

Includes:

PHP 8.2 FPM

Redis extension

OPcache tuning

WP-CLI preinstalled

3. MySQL (StatefulSet)

Optimized for WordPress:

innodb_buffer_pool_size=1G
innodb_log_file_size=256M
query_cache_size=64M
slow_query_log=1

📊 Monitoring & Alerting
Metrics Collected
Nginx

Request count

Latency (P95/P99)

5xx error rate

WordPress

PHP-FPM usage

Slow requests

Memory/CPU

MySQL

Query rate

Slow queries

Buffer pool usage

Kubernetes

Pod CPU/memory

Restarts

PVC usage

Grafana Dashboard Includes
Metric	Alert
Pod CPU	> 80%
5xx Errors	> 5%
Latency	> 2s
MySQL slow queries	> 10/min
🔔 Alert Rules (Prometheus)
Critical Alerts
- alert: MySQLDown
  expr: mysql_up == 0
  severity: critical

Warning Alerts
- alert: HighMemoryUsage
  expr: container_memory_usage > 0.85

🧰 Operational Commands
Scale pods
kubectl scale deploy my-wordpress -n wordpress --replicas=5

Upgrade WordPress
helm upgrade my-wordpress ./helm/wordpress \
  --set image.wordpress.tag=6.4.2 \
  --reuse-values

Backup DB
kubectl exec my-wordpress-mysql-0 -n wordpress -- \
  mysqldump -u root -pPASSWORD wordpress > backup.sql

🛠️ Troubleshooting
PVC Pending
kubectl logs -n kube-system -l app=nfs-provisioner

High 5xx Errors

Check:

kubectl logs -n wordpress -l app=nginx -c nginx

MySQL Connection Errors
kubectl exec -n wordpress POD -- mysql -h mysql -u wordpress -p

✅ Post-Deployment Checklist

 Pods running

 PVCs bound

 Metrics available

 Grafana dashboards visible

 Alerts firing correctly

 External WordPress URL accessible

📜 License

MIT