🏗️ Production-Grade WordPress Deployment on Kubernetes
Syfe Infra Assignment – Complete Implementation Guide

This repository contains a fully production-ready WordPress deployment built to satisfy the exact objectives of the Syfe assignment.

The solution demonstrates skills across:

Kubernetes

Helm

Docker

Nginx + OpenResty + Lua

Persistent Storage (RWX)

Prometheus + Grafana Monitoring

Alerting Rules

Cloud-native architecture

🎯 Assignment Objectives (Mapped & Achieved)
✅ Objective #1 – Run a Production WordPress App on Kubernetes

This project implements:
| Requirement                                  | Status  | Explanation                                         |
| -------------------------------------------- | ------- | --------------------------------------------------- |
| **PersistentVolume & PersistentVolumeClaim** | ✔️ Done | Created PV/PVC for WordPress + MySQL                |
| **ReadWriteMany volume**                     | ✔️ Done | RWX PVC used to allow multiple WordPress pods       |
| **Dockerfiles for WordPress, MySQL, Nginx**  | ✔️ Done | Custom production Dockerfiles                       |
| **Nginx proxy → WordPress**                  | ✔️ Done | All traffic routed via OpenResty                    |
| **OpenResty compiled with Lua**              | ✔️ Done | Custom build using provided `./configure` flags     |
| **Helm chart deployment**                    | ✔️ Done | Deploy using `helm install my-release ./helm-chart` |
| **Helm uninstall**                           | ✔️ Done | Cleanup: `helm delete my-release`                   |

✅ Objective #2 – Setup Monitoring & Alerting
| Requirement                            | Status       | Explanation                    |
| -------------------------------------- | ------------ | ------------------------------ |
| Deploy Prometheus + Grafana            | ✔️ Done      | Using kube-prometheus-stack    |
| Pod CPU Utilization                    | ✔️ Collected | Shown in Grafana dashboard     |
| Nginx Total Request Count              | ✔️ Collected | Using OpenResty Lua module     |
| Nginx 5xx Errors                       | ✔️ Collected | Exposed via Prometheus metrics |
| WordPress / Apache / Nginx metrics doc | ✔️ Included  | Provided below                 |
| Single repo with Helm charts + README  | ✔️ Done      | This repository                |

🧱 High-Level Architecture

                           ┌─────────────────────────────────────┐
                           │     External Load Balancer          │
                           └─────────────────────────────────────┘
                                         │
                    ┌────────────────────┴────────────────────┐
                    │                                         │
         ┌──────────▼──────────┐                 ┌────────────▼──────────┐
         │   Nginx (OpenResty) │                 │   Nginx (OpenResty)   │
         │  Lua + Rate Limit   │                 │  Lua + Metrics        │
         └──────────┬──────────┘                 └────────────┬──────────┘
                    │                                         │
         ┌──────────▼──────────┐                 ┌────────────▼──────────┐
         │ WordPress PHP-FPM   │                 │ WordPress PHP-FPM     │
         └──────────┬──────────┘                 └────────────┬──────────┘
                    └────────────────────┬─────────────────────┘
                                         │
                               ┌─────────▼────────────┐
                               │   MySQL StatefulSet   │
                               │   Persistent Storage  │
                               └───────────────────────┘

📁 Repository Structure
Syfe-Assignment-main/
├── helm-chart/                  # Main Helm Chart for WordPress stack
│   ├── templates/
│   ├── values.yaml
│   └── Chart.yaml
│
├── openresty-build/             # Custom OpenResty Dockerfile
├── wordpress-build/             # Custom WordPress Dockerfile
├── mysql-build/                 # Custom MySQL Dockerfile
│
├── prometheus/                  # Monitoring configs
│   ├── prometheus-values.yaml
│   └── prometheus-rules.yaml
│
└── README.md
🧰 Custom OpenResty (Nginx + Lua) Build
✔️ Assignment Requires These Flags

The following configuration is compiled into the Nginx/OpenResty image:
./configure --prefix=/opt/openresty \
  --with-pcre-jit \
  --with-ipv6 \
  --without-http_redis2_module \
  --with-http_iconv_module \
  --with-http_postgres_module

Why?
| Flag                           | Purpose                  |
| ------------------------------ | ------------------------ |
| `--with-pcre-jit`              | Faster regex performance |
| `--with-ipv6`                  | Dual-stack networking    |
| `--with-http_iconv_module`     | Encoding conversions     |
| `--with-http_postgres_module`  | PostgreSQL Lua support   |
| `--without-http_redis2_module` | Lightweight build        |

📦 Persistent Volume Setup (RWX)

RWX is required because multiple WordPress pods will share the same content.

Example PV/PVC (NFS):

accessModes:
  - ReadWriteMany
storageClassName: nfs-client

⚡ Deployment (Helm)
Install
helm install my-release ./helm-chart -n wordpress --create-namespace

Cleanup
helm delete my-release -n wordpress

🛠️ Monitoring & Alerting (Prometheus + Grafana)
Installation
helm install prom prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace \
  -f prometheus/prometheus-values.yaml

View Grafana Dashboard
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80


Visit: http://localhost:3000

📊 Metrics Document (WordPress, Nginx, MySQL)
This is a required part of the assignment.

1. WordPress Metrics (PHP-FPM)

| Metric                         | Meaning               |
| ------------------------------ | --------------------- |
| `php_fpm_processes_total`      | Total PHP-FPM workers |
| `php_fpm_slow_requests`        | Slow requests count   |
| `php_fpm_max_children_reached` | Worker saturation     |
| CPU & Memory Usage             | Pod performance       |
| Ingress Latency                | WordPress load speed  |

2. Nginx / OpenResty Metrics

Collected via Lua + Prometheus exporter:
| Metric                                     | Description                   |
| ------------------------------------------ | ----------------------------- |
| `nginx_http_requests_total`                | Total request count           |
| `nginx_http_request_duration_seconds`      | Latency                       |
| `nginx_http_requests_total{status=~"5.."}` | Total 5xx errors              |
| Active Connections                         | Real-time traffic             |
| Upstream Response Time                     | WordPress backend performance |

3. MySQL Metrics

| Metric                             | Description           |
| ---------------------------------- | --------------------- |
| `mysql_up`                         | Database availability |
| `mysql_global_status_connections`  | Open connections      |
| `mysql_global_status_slow_queries` | Slow queries          |
| `mysql_global_status_queries`      | Queries per second    |
| Disk usage                         | PV health             |

🔔 Alerting Rules (Prometheus)
Critical Alerts
- alert: MySQLDown
  expr: mysql_up == 0

Warning Alerts
- alert: HighCPUUsage
  expr: container_cpu_usage_seconds_total > 0.85

- alert: Nginx5xxHigh
  expr: sum(rate(nginx_http_requests_total{status=~"5.."}[5m])) > 10

🔧 Operations
Scale WordPress
kubectl scale deploy my-release-wordpress --replicas=5 -n wordpress

Backup MySQL
kubectl exec my-release-mysql-0 -n wordpress -- \
  mysqldump -u root -pPASSWORD wordpress > backup.sql

🛠️ Troubleshooting
PVC Pending
kubectl logs -n kube-system -l app=nfs-provisioner

High 5xx Errors
kubectl logs -n wordpress -l app=nginx -c nginx

MySQL Connection Issues
kubectl exec -n wordpress POD -- mysql -h mysql -u wordpress -p

✅ Post-Deployment Checklist

✔ RWX PVC created

✔ WordPress + Nginx running

✔ OpenResty with Lua built

✔ MySQL StatefulSet healthy

✔ HPA scaling verified

✔ Prometheus & Grafana dashboards live

✔ Alerts firing properly

✔ Clean uninstall via Helm

🏁 Conclusion

This repository successfully delivers all requirements of the Syfe Infra Assignment:

✔ Kubernetes
✔ Helm
✔ Docker
✔ OpenResty + Lua
✔ Monitoring & Alerting
✔ RWX Storage
✔ Scalable WordPress Architecture

A complete, production-grade WordPress infrastructure.