🏗️ WordPress Production Deployment on Kubernetes

Enterprise-Grade, Scalable, Secure & Monitored WordPress Setup

This repository provides a production-ready, highly scalable WordPress deployment on Kubernetes designed for:

High availability

Horizontal scaling

Enterprise performance

Deep monitoring & alerting

The setup includes:

OpenResty/Nginx + Lua for advanced routing & security

Optimized MySQL StatefulSet

Prometheus + Grafana monitoring

ReadWriteMany persistent storage for multi-pod scaling

| Category        | Features                                                     |
| --------------- | ------------------------------------------------------------ |
| **Scalability** | HPA (3–10 replicas), RWX volumes, load-balanced architecture |
| **Performance** | OpenResty + Lua, PHP-FPM tuning, Redis-ready                 |
| **Reliability** | MySQL StatefulSet, auto-recovery, persistent volumes         |
| **Monitoring**  | Kube-Prometheus, 50+ metrics, Grafana dashboards             |
| **Security**    | Lua rate limiting, hardened configs                          |
| **Storage**     | RWX (NFS/CephFS)                                             |
| **Automation**  | Fully Helm-based deployment                                  |

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
                               │   MySQL StatefulSet │
                               └─────────────────────┘

| Tool       | Version | Purpose                |
| ---------- | ------- | ---------------------- |
| Kubernetes | 1.24+   | Deployment environment |
| Helm       | 3.x     | Package management     |
| Docker     | 20.10+  | Image builds           |
| kubectl    | 1.24+   | K8s CLI                |

Cluster Requirements

4+ vCPU, 8GB RAM

RWX storage class (NFS, CephFS, EFS, GlusterFS)

LoadBalancer support (AWS/GCP/Azure/MetalLB)

⚡ Quick Start
1️⃣ Clone Repository
git clone https://github.com/somil108/syfe-infra-assignment.git
cd syfe-infra-assignment

2️⃣ Build & Push Images
docker build -t your/openresty:latest openresty-build/
docker build -t your/wordpress:latest wordpress-build/
docker build -t your/mysql:8.0 mysql-build/

3️⃣ Configure Helm Values
cp helm-chart/values.example.yaml helm-chart/values.yaml


Update:

Image registry

DB credentials

Storage class

Autoscaling settings

4️⃣ Deploy WordPress
helm install my-wordpress ./helm-chart \
  --namespace wordpress \
  --create-namespace

5️⃣ Deploy Monitoring
helm install prom prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace \
  -f prometheus/prometheus-values.yaml

6️⃣ Access Services
kubectl get svc -n wordpress
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80

📁 Repository Structure
Syfe-Assignment-main/
├── helm-chart/
├── mysql-build/
├── nginx-build/
├── openresty-build/
├── prometheus/
├── wordpress-build/
└── README.md

🔧 Custom Components
1. OpenResty / Nginx

Lua rate limiting

Security headers

Prometheus metrics endpoint

Custom routing logic

2. WordPress PHP-FPM

PHP 8.2 FPM

Redis extension

OPcache tuning

WP-CLI included

3. MySQL StatefulSet

WordPress optimized config

Slow query logging

InnoDB tuning

📊 Monitoring & Alerting

Includes:

Nginx request metrics

PHP-FPM performance

MySQL slow queries

Pod CPU/RAM

Disk/PVC usage

Prometheus rules include:

Critical
- alert: MySQLDown
  expr: mysql_up == 0

Warning
- alert: HighMemoryUsage
  expr: container_memory_usage > 0.85

🧰 Operations
Scale Pods
kubectl scale deploy my-wordpress -n wordpress --replicas=5

Upgrade WordPress
helm upgrade my-wordpress ./helm-chart \
  --set image.wordpress.tag=6.4.2

Backup Database
kubectl exec my-wordpress-mysql-0 -n wordpress -- \
  mysqldump -u root -pPASSWORD wordpress > backup.sql

🛠️ Troubleshooting

PVC Pending:

kubectl logs -n kube-system -l app=nfs-provisioner


High 5xx errors:

kubectl logs -n wordpress -l app=nginx -c nginx


MySQL connection errors:

kubectl exec -n wordpress POD -- mysql -h mysql -u wordpress -p

✅ Post-Deployment Checklist

✔ Pods running
✔ PVCs bound
✔ Metrics visible in Grafana
✔ Alerts firing
✔ WordPress URL active

📜 License

MIT