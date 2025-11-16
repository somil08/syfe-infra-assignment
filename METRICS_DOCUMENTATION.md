# Metrics Documentation - WordPress Monitoring

**Author:** Somil Rathore  
**Institution:** Indian Institute of Information Technology, Bhopal

## Table of Contents

1. [Overview](#overview)
2. [Container Metrics](#container-metrics)
3. [Nginx Metrics](#nginx-metrics)
4. [WordPress Metrics](#wordpress-metrics)
5. [MySQL Metrics](#mysql-metrics)
6. [Kubernetes Cluster Metrics](#kubernetes-cluster-metrics)
7. [Alert Rules](#alert-rules)
8. [Grafana Dashboards](#grafana-dashboards)
9. [Custom Metrics](#custom-metrics)

---

## Overview

This document describes all metrics collected for the WordPress application running on Kubernetes, including container metrics, application-specific metrics, and infrastructure metrics.

### Metrics Collection Architecture

```
┌─────────────────┐
│  Applications   │
│  (Nginx, WP,    │
│   MySQL)        │
└────────┬────────┘
         │ Expose metrics
         ▼
┌─────────────────┐
│   Prometheus    │  ← Scrapes metrics every 30s
│   (Collector)   │
└────────┬────────┘
         │ Query metrics
         ▼
┌─────────────────┐
│    Grafana      │  ← Visualize & Alert
│  (Dashboard)    │
└─────────────────┘
```

---

## Container Metrics

### 1. Pod CPU Utilization

**Metric Name:** `container_cpu_usage_seconds_total`

**Description:** Total CPU time consumed by containers in seconds.

**Type:** Counter

**Labels:**
- `pod`: Pod name
- `namespace`: Kubernetes namespace
- `container`: Container name
- `node`: Node name

**PromQL Queries:**

```promql
# CPU usage rate (percentage)
rate(container_cpu_usage_seconds_total{pod=~".*wordpress.*"}[5m]) * 100

# CPU usage by pod
sum(rate(container_cpu_usage_seconds_total{pod=~".*wordpress.*"}[5m])) by (pod)

# CPU usage percentage (relative to limits)
rate(container_cpu_usage_seconds_total[5m]) / 
container_spec_cpu_quota * 100
```

**Alert Threshold:** > 80% for 5 minutes

**Grafana Visualization:** Time series graph, Gauge

---

### 2. Pod Memory Utilization

**Metric Name:** `container_memory_usage_bytes`

**Description:** Current memory usage in bytes.

**Type:** Gauge

**Labels:**
- `pod`: Pod name
- `namespace`: Kubernetes namespace
- `container`: Container name
- `node`: Node name

**PromQL Queries:**

```promql
# Memory usage in MB
container_memory_usage_bytes{pod=~".*wordpress.*"} / 1024 / 1024

# Memory usage by pod
sum(container_memory_usage_bytes{pod=~".*wordpress.*"}) by (pod)

# Memory usage percentage (relative to limits)
container_memory_usage_bytes / 
container_spec_memory_limit_bytes * 100
```

**Alert Threshold:** > 80% for 5 minutes

**Grafana Visualization:** Time series graph, Gauge

---

### 3. Container Restart Count

**Metric Name:** `kube_pod_container_status_restarts_total`

**Description:** Total number of container restarts.

**Type:** Counter

**Labels:**
- `pod`: Pod name
- `namespace`: Kubernetes namespace
- `container`: Container name

**PromQL Queries:**

```promql
# Total restarts
kube_pod_container_status_restarts_total{pod=~".*wordpress.*"}

# Restart rate
rate(kube_pod_container_status_restarts_total{pod=~".*wordpress.*"}[15m])

# Pods with recent restarts
kube_pod_container_status_restarts_total > 0
```

**Alert Threshold:** > 0 restarts in 15 minutes

**Grafana Visualization:** Single stat, Table

---

### 4. Pod Network I/O

**Metric Names:**
- `container_network_receive_bytes_total`
- `container_network_transmit_bytes_total`

**Description:** Network traffic in/out of containers.

**Type:** Counter

**PromQL Queries:**

```promql
# Network receive rate (MB/s)
rate(container_network_receive_bytes_total{pod=~".*wordpress.*"}[5m]) / 1024 / 1024

# Network transmit rate (MB/s)
rate(container_network_transmit_bytes_total{pod=~".*wordpress.*"}[5m]) / 1024 / 1024

# Total network traffic
sum(rate(container_network_receive_bytes_total[5m])) by (pod) +
sum(rate(container_network_transmit_bytes_total[5m])) by (pod)
```

**Grafana Visualization:** Time series graph

---

### 5. Disk I/O

**Metric Names:**
- `container_fs_reads_bytes_total`
- `container_fs_writes_bytes_total`

**Description:** Filesystem read/write operations.

**Type:** Counter

**PromQL Queries:**

```promql
# Disk read rate (MB/s)
rate(container_fs_reads_bytes_total{pod=~".*wordpress.*"}[5m]) / 1024 / 1024

# Disk write rate (MB/s)
rate(container_fs_writes_bytes_total{pod=~".*wordpress.*"}[5m]) / 1024 / 1024
```

**Grafana Visualization:** Time series graph

---

## Nginx Metrics

### 1. Total Request Count

**Metric Name:** `nginx_http_requests_total`

**Description:** Total number of HTTP requests processed by Nginx.

**Type:** Counter

**Labels:**
- `instance`: Nginx instance
- `job`: Scrape job name

**PromQL Queries:**

```promql
# Total requests
nginx_http_requests_total

# Request rate (requests per second)
rate(nginx_http_requests_total[5m])

# Total requests in last hour
increase(nginx_http_requests_total[1h])
```

**Grafana Visualization:** Single stat (total), Time series (rate)

---

### 2. Total 5xx Errors

**Metric Name:** `nginx_http_requests_5xx`

**Description:** Total number of 5xx HTTP responses.

**Type:** Counter

**Labels:**
- `instance`: Nginx instance
- `job`: Scrape job name

**PromQL Queries:**

```promql
# Total 5xx errors
nginx_http_requests_5xx

# 5xx error rate
rate(nginx_http_requests_5xx[5m])

# 5xx error percentage
rate(nginx_http_requests_5xx[5m]) / 
rate(nginx_http_requests_total[5m]) * 100
```

**Alert Threshold:** > 10 errors per second for 2 minutes

**Grafana Visualization:** Time series graph, Single stat

---

### 3. HTTP Status Code Distribution

**Metric Names:**
- `nginx_http_requests_2xx` (Success)
- `nginx_http_requests_3xx` (Redirects)
- `nginx_http_requests_4xx` (Client errors)
- `nginx_http_requests_5xx` (Server errors)

**Description:** Distribution of HTTP response codes.

**Type:** Counter

**PromQL Queries:**

```promql
# Status code distribution
sum(rate(nginx_http_requests_2xx[5m])) by (instance)
sum(rate(nginx_http_requests_3xx[5m])) by (instance)
sum(rate(nginx_http_requests_4xx[5m])) by (instance)
sum(rate(nginx_http_requests_5xx[5m])) by (instance)

# Success rate percentage
rate(nginx_http_requests_2xx[5m]) / 
rate(nginx_http_requests_total[5m]) * 100
```

**Grafana Visualization:** Pie chart, Stacked graph

---

### 4. Request Latency

**Metric Name:** `nginx_http_request_duration_seconds`

**Description:** HTTP request processing time.

**Type:** Histogram

**PromQL Queries:**

```promql
# Average request duration
rate(nginx_http_request_duration_seconds_sum[5m]) / 
rate(nginx_http_request_duration_seconds_count[5m])

# 95th percentile latency
histogram_quantile(0.95, 
  rate(nginx_http_request_duration_seconds_bucket[5m]))

# 99th percentile latency
histogram_quantile(0.99, 
  rate(nginx_http_request_duration_seconds_bucket[5m]))
```

**Alert Threshold:** > 2 seconds (p95) for 5 minutes

**Grafana Visualization:** Time series graph, Heatmap

---

### 5. Active Connections

**Metric Name:** `nginx_connections_active`

**Description:** Number of active client connections.

**Type:** Gauge

**PromQL Queries:**

```promql
# Current active connections
nginx_connections_active

# Average active connections
avg_over_time(nginx_connections_active[5m])

# Max active connections
max_over_time(nginx_connections_active[1h])
```

**Grafana Visualization:** Time series graph, Gauge

---

### 6. Upstream Response Time

**Metric Name:** `nginx_upstream_response_time_seconds`

**Description:** Time to receive response from upstream (WordPress).

**Type:** Histogram

**PromQL Queries:**

```promql
# Average upstream response time
rate(nginx_upstream_response_time_seconds_sum[5m]) / 
rate(nginx_upstream_response_time_seconds_count[5m])

# Slow upstream requests (> 1s)
nginx_upstream_response_time_seconds_bucket{le="1.0"}
```

**Grafana Visualization:** Time series graph

---

## WordPress Metrics

### 1. PHP-FPM Status

**Metrics Available:**
- `phpfpm_up`: PHP-FPM availability
- `phpfpm_accepted_connections`: Total accepted connections
- `phpfpm_active_processes`: Currently active processes
- `phpfpm_idle_processes`: Idle processes
- `phpfpm_max_active_processes`: Maximum active processes reached

**PromQL Queries:**

```promql
# PHP-FPM availability
phpfpm_up

# Active processes
phpfpm_active_processes

# Process utilization
phpfpm_active_processes / 
(phpfpm_active_processes + phpfpm_idle_processes) * 100
```

**Grafana Visualization:** Time series graph, Gauge

---

### 2. WordPress Response Time

**Metric Name:** `wordpress_response_time_seconds`

**Description:** WordPress page generation time.

**Type:** Histogram

**PromQL Queries:**

```promql
# Average response time
rate(wordpress_response_time_seconds_sum[5m]) / 
rate(wordpress_response_time_seconds_count[5m])

# Slow pages (> 2s)
wordpress_response_time_seconds_bucket{le="2.0"}
```

**Alert Threshold:** > 3 seconds (average) for 5 minutes

**Grafana Visualization:** Time series graph

---

### 3. WordPress Cache Hit Rate

**Metric Name:** `wordpress_cache_hits_total` / `wordpress_cache_misses_total`

**Description:** Object cache performance.

**Type:** Counter

**PromQL Queries:**

```promql
# Cache hit rate
rate(wordpress_cache_hits_total[5m]) / 
(rate(wordpress_cache_hits_total[5m]) + 
 rate(wordpress_cache_misses_total[5m])) * 100
```

**Grafana Visualization:** Time series graph, Single stat

---

## MySQL Metrics

### 1. Query Performance

**Metrics:**
- `mysql_global_status_queries`: Total queries
- `mysql_global_status_slow_queries`: Slow queries
- `mysql_global_status_questions`: Client queries

**PromQL Queries:**

```promql
# Query rate
rate(mysql_global_status_queries[5m])

# Slow query rate
rate(mysql_global_status_slow_queries[5m])

# Slow query percentage
rate(mysql_global_status_slow_queries[5m]) / 
rate(mysql_global_status_queries[5m]) * 100
```

**Alert Threshold:** > 5% slow queries

**Grafana Visualization:** Time series graph

---

### 2. Connection Count

**Metrics:**
- `mysql_global_status_threads_connected`: Current connections
- `mysql_global_status_max_used_connections`: Max connections used
- `mysql_global_variables_max_connections`: Max connections allowed

**PromQL Queries:**

```promql
# Current connections
mysql_global_status_threads_connected

# Connection usage percentage
mysql_global_status_threads_connected / 
mysql_global_variables_max_connections * 100
```

**Alert Threshold:** > 80% of max connections

**Grafana Visualization:** Time series graph, Gauge

---

### 3. Database Size

**Metric Name:** `mysql_info_schema_table_size_bytes`

**Description:** Size of database tables.

**Type:** Gauge

**PromQL Queries:**

```promql
# Total database size (GB)
sum(mysql_info_schema_table_size_bytes{schema="wordpress"}) / 1024 / 1024 / 1024

# Size by table
sum(mysql_info_schema_table_size_bytes{schema="wordpress"}) by (table)
```

**Grafana Visualization:** Single stat, Table

---

### 4. InnoDB Buffer Pool

**Metrics:**
- `mysql_global_status_innodb_buffer_pool_pages_total`
- `mysql_global_status_innodb_buffer_pool_pages_free`
- `mysql_global_status_innodb_buffer_pool_read_requests`

**PromQL Queries:**

```promql
# Buffer pool usage
(mysql_global_status_innodb_buffer_pool_pages_total - 
 mysql_global_status_innodb_buffer_pool_pages_free) / 
mysql_global_status_innodb_buffer_pool_pages_total * 100

# Buffer pool hit rate
rate(mysql_global_status_innodb_buffer_pool_read_requests[5m]) / 
(rate(mysql_global_status_innodb_buffer_pool_read_requests[5m]) + 
 rate(mysql_global_status_innodb_buffer_pool_reads[5m])) * 100
```

**Grafana Visualization:** Time series graph, Gauge

---

## Kubernetes Cluster Metrics

### 1. Node Resources

**Metrics:**
- `node_cpu_seconds_total`: Node CPU usage
- `node_memory_MemTotal_bytes`: Total node memory
- `node_memory_MemAvailable_bytes`: Available node memory

**PromQL Queries:**

```promql
# Node CPU usage
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Node memory usage
(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / 
node_memory_MemTotal_bytes * 100
```

**Grafana Visualization:** Time series graph, Gauge per node

---

### 2. Pod Status

**Metrics:**
- `kube_pod_status_phase`: Pod phase (Running, Pending, Failed)
- `kube_pod_status_ready`: Pod readiness
- `kube_pod_container_status_running`: Container running status

**PromQL Queries:**

```promql
# Running pods
count(kube_pod_status_phase{phase="Running"})

# Pods by phase
sum(kube_pod_status_phase) by (phase)

# Not ready pods
count(kube_pod_status_ready{condition="false"})
```

**Grafana Visualization:** Single stat, Table

---

### 3. Persistent Volume Usage

**Metrics:**
- `kubelet_volume_stats_capacity_bytes`: PV capacity
- `kubelet_volume_stats_used_bytes`: PV used space

**PromQL Queries:**

```promql
# PV usage percentage
kubelet_volume_stats_used_bytes / 
kubelet_volume_stats_capacity_bytes * 100

# Available space (GB)
(kubelet_volume_stats_capacity_bytes - 
 kubelet_volume_stats_used_bytes) / 1024 / 1024 / 1024
```

**Alert Threshold:** > 85% usage

**Grafana Visualization:** Time series graph, Gauge

---

## Alert Rules

### Critical Alerts

1. **Service Down**
   - Condition: `up == 0`
   - Duration: 2 minutes
   - Action: Page on-call engineer

2. **High 5xx Error Rate**
   - Condition: `rate(nginx_http_requests_5xx[5m]) > 10`
   - Duration: 2 minutes
   - Action: Alert development team

3. **Database Connection Failure**
   - Condition: `mysql_up == 0`
   - Duration: 1 minute
   - Action: Page on-call engineer

### Warning Alerts

1. **High CPU Usage**
   - Condition: `rate(container_cpu_usage_seconds_total[5m]) > 0.8`
   - Duration: 5 minutes
   - Action: Notify operations team

2. **High Memory Usage**
   - Condition: `container_memory_usage_bytes / container_spec_memory_limit_bytes > 0.8`
   - Duration: 5 minutes
   - Action: Notify operations team

3. **Pod Restarting**
   - Condition: `rate(kube_pod_container_status_restarts_total[15m]) > 0`
   - Duration: 5 minutes
   - Action: Notify development team

4. **Slow Response Time**
   - Condition: `histogram_quantile(0.95, rate(nginx_http_request_duration_seconds_bucket[5m])) > 2`
   - Duration: 5 minutes
   - Action: Notify development team

---

## Grafana Dashboards

### 1. WordPress Overview Dashboard

**Panels:**
- Request rate (requests/sec)
- Error rate (5xx/4xx)
- Response time (p50, p95, p99)
- Active connections
- Pod status
- Resource usage (CPU, Memory)

### 2. Nginx Performance Dashboard

**Panels:**
- Total requests
- Status code distribution
- Request latency heatmap
- Upstream response time
- Active connections
- Error rate over time

### 3. Database Performance Dashboard

**Panels:**
- Query rate
- Slow queries
- Connection count
- Buffer pool hit rate
- InnoDB metrics
- Table sizes

### 4. Kubernetes Cluster Dashboard

**Panels:**
- Node resource usage
- Pod status by namespace
- PV usage
- Network I/O
- Container restarts
- Cluster capacity

---

## Custom Metrics

### Adding Custom Metrics

1. **Application-level metrics** (WordPress plugins)
2. **Business metrics** (user registrations, page views)
3. **Custom Lua metrics** (Nginx)

### Example: Custom Lua Metric

```lua
-- In Nginx Lua script
local metrics = ngx.shared.prometheus_metrics
metrics:incr("custom_metric_total", 1)
```

### Exporting Custom Metrics

```lua
-- In metrics.lua
local custom_total = metrics:get("custom_metric_total") or 0
output = output .. string.format([[
# HELP custom_metric_total Custom metric description
# TYPE custom_metric_total counter
custom_metric_total %d
]], custom_total)
```

---

## Metrics Retention

- **Prometheus:** 15 days (configurable in values.yaml)
- **Grafana:** Unlimited (stored in PostgreSQL)
- **Long-term storage:** Consider Thanos or Cortex for > 15 days

---

## Best Practices

1. **Set appropriate scrape intervals** (30s default)
2. **Use recording rules** for expensive queries
3. **Implement proper labeling** for filtering
4. **Set up alerting** for critical metrics
5. **Regular dashboard reviews** and updates
6. **Monitor monitoring** (Prometheus/Grafana health)

---

## References

- Prometheus Documentation: https://prometheus.io/docs/
- Grafana Documentation: https://grafana.com/docs/
- Kubernetes Metrics: https://kubernetes.io/docs/tasks/debug/debug-cluster/resource-metrics-pipeline/
- OpenResty Lua: https://openresty.org/en/

---

**For deployment instructions, see [DEPLOYMENT_GUIDE.md](./DEPLOYMENT_GUIDE.md)**
