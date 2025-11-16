# Troubleshooting Guide

**Project:** WordPress on Kubernetes  
**Author:** Somil Rathore

---

## Table of Contents

1. [Common Issues](#common-issues)
2. [Docker Build Issues](#docker-build-issues)
3. [Kubernetes Deployment Issues](#kubernetes-deployment-issues)
4. [Helm Issues](#helm-issues)
5. [Networking Issues](#networking-issues)
6. [Storage Issues](#storage-issues)
7. [Monitoring Issues](#monitoring-issues)
8. [Performance Issues](#performance-issues)
9. [Debugging Commands](#debugging-commands)

---

## Common Issues

### Issue: kubectl command not found

**Symptoms:**
```
'kubectl' is not recognized as an internal or external command
```

**Solution:**
1. Install kubectl: https://kubernetes.io/docs/tasks/tools/
2. Add to PATH
3. Verify: `kubectl version --client`

---

### Issue: Helm command not found

**Symptoms:**
```
'helm' is not recognized as an internal or external command
```

**Solution:**
1. Install Helm: https://helm.sh/docs/intro/install/
2. Add to PATH
3. Verify: `helm version`

---

### Issue: Cannot connect to Kubernetes cluster

**Symptoms:**
```
The connection to the server localhost:8080 was refused
```

**Solution:**

**For Minikube:**
```bash
# Start Minikube
minikube start

# Verify
kubectl cluster-info
```

**For other clusters:**
```bash
# Check kubeconfig
kubectl config view

# Set correct context
kubectl config use-context <context-name>
```

---

## Docker Build Issues

### Issue: Docker build fails for Nginx

**Symptoms:**
```
ERROR: failed to solve: process "/bin/sh -c ./configure ..." did not complete successfully
```

**Solution:**
1. Check internet connectivity
2. Verify OpenResty version is available
3. Ensure sufficient disk space
4. Try building with `--no-cache`:
   ```bash
   docker build --no-cache -t wordpress-nginx:latest ./docker/nginx
   ```

---

### Issue: Docker build slow

**Symptoms:**
- Build takes very long time
- Downloading packages is slow

**Solution:**
1. Use Docker build cache
2. Check internet speed
3. Use local mirror for packages
4. Increase Docker resources (CPU/Memory)

---

### Issue: Permission denied during build

**Symptoms:**
```
permission denied while trying to connect to the Docker daemon socket
```

**Solution:**

**Linux:**
```bash
sudo usermod -aG docker $USER
newgrp docker
```

**Windows:**
- Run Docker Desktop as Administrator
- Restart Docker Desktop

---

## Kubernetes Deployment Issues

### Issue: Pods stuck in Pending state

**Symptoms:**
```
NAME                          READY   STATUS    RESTARTS   AGE
my-release-mysql-xxx          0/1     Pending   0          5m
```

**Diagnosis:**
```bash
kubectl describe pod <pod-name>
```

**Common Causes:**

1. **Insufficient resources**
   ```bash
   # Check node resources
   kubectl top nodes
   
   # Solution: Increase cluster resources or reduce pod requests
   ```

2. **PVC not bound**
   ```bash
   # Check PVC status
   kubectl get pvc
   
   # Solution: Check storage class, create PV manually
   ```

3. **Image pull errors**
   ```bash
   # Check events
   kubectl get events --sort-by='.lastTimestamp'
   
   # Solution: Load images to Minikube or push to registry
   ```

---

### Issue: Pods in CrashLoopBackOff

**Symptoms:**
```
NAME                          READY   STATUS             RESTARTS   AGE
my-release-mysql-xxx          0/1     CrashLoopBackOff   5          5m
```

**Diagnosis:**
```bash
# Check logs
kubectl logs <pod-name>

# Check previous logs
kubectl logs <pod-name> --previous

# Describe pod
kubectl describe pod <pod-name>
```

**Common Causes:**

1. **Application error**
   - Check logs for error messages
   - Verify environment variables
   - Check configuration files

2. **Health check failing**
   ```bash
   # Disable health checks temporarily to debug
   kubectl edit deployment <deployment-name>
   # Comment out livenessProbe and readinessProbe
   ```

3. **Missing dependencies**
   - Check if MySQL is ready before WordPress starts
   - Verify init containers

---

### Issue: ImagePullBackOff

**Symptoms:**
```
NAME                          READY   STATUS             RESTARTS   AGE
my-release-nginx-xxx          0/1     ImagePullBackOff   0          2m
```

**Solution:**

**For Minikube:**
```bash
# Load images to Minikube
minikube image load wordpress-nginx:latest
minikube image load wordpress-custom:latest
minikube image load mysql-custom:latest

# Verify images
minikube image ls | grep wordpress
```

**For other clusters:**
```bash
# Push to registry
docker tag wordpress-nginx:latest your-registry/wordpress-nginx:latest
docker push your-registry/wordpress-nginx:latest

# Update values.yaml with registry path
```

---

### Issue: Init container failing

**Symptoms:**
```
NAME                          READY   STATUS     RESTARTS   AGE
my-release-wordpress-xxx      0/1     Init:0/1   0          2m
```

**Diagnosis:**
```bash
# Check init container logs
kubectl logs <pod-name> -c <init-container-name>

# Example
kubectl logs my-release-wordpress-xxx -c wait-for-mysql
```

**Solution:**
- Verify MySQL service is running
- Check service name in init container
- Increase timeout if needed

---

## Helm Issues

### Issue: Helm install fails

**Symptoms:**
```
Error: INSTALLATION FAILED: unable to build kubernetes objects from release manifest
```

**Diagnosis:**
```bash
# Validate chart
helm lint ./helm-charts/wordpress-app

# Dry run
helm install my-release ./helm-charts/wordpress-app --dry-run --debug
```

**Common Causes:**

1. **Template errors**
   - Check YAML syntax
   - Verify template functions
   - Use `helm template` to render

2. **Missing values**
   - Check required values in values.yaml
   - Provide all required parameters

---

### Issue: Helm dependency update fails

**Symptoms:**
```
Error: unable to get an update from the "prometheus-community" chart repository
```

**Solution:**
```bash
# Add repositories
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts

# Update repositories
helm repo update

# Update dependencies
cd helm-charts/monitoring
helm dependency update
```

---

### Issue: Helm release already exists

**Symptoms:**
```
Error: INSTALLATION FAILED: cannot re-use a name that is still in use
```

**Solution:**
```bash
# List releases
helm list

# Delete existing release
helm delete my-release

# Wait for cleanup
kubectl get pods

# Reinstall
helm install my-release ./helm-charts/wordpress-app
```

---

## Networking Issues

### Issue: Cannot access WordPress

**Symptoms:**
- Port forward not working
- Service not accessible

**Diagnosis:**
```bash
# Check service
kubectl get svc nginx-service

# Check endpoints
kubectl get endpoints nginx-service

# Check pods
kubectl get pods -l component=nginx
```

**Solution:**

1. **Port forward not working**
   ```bash
   # Kill existing port-forward
   pkill -f "port-forward"
   
   # Start new port-forward
   kubectl port-forward svc/nginx-service 8080:80
   ```

2. **Service has no endpoints**
   ```bash
   # Check pod labels match service selector
   kubectl get pods --show-labels
   kubectl describe svc nginx-service
   ```

3. **Firewall blocking**
   - Check Windows Firewall
   - Allow kubectl through firewall
   - Try different port

---

### Issue: Nginx cannot reach WordPress

**Symptoms:**
- 502 Bad Gateway
- Connection refused errors

**Diagnosis:**
```bash
# Check WordPress service
kubectl get svc wordpress-service

# Test from Nginx pod
kubectl exec -it <nginx-pod> -- curl http://wordpress-service:9000
```

**Solution:**
1. Verify WordPress pods are running
2. Check service name in Nginx config
3. Verify port numbers match

---

## Storage Issues

### Issue: PVC stuck in Pending

**Symptoms:**
```
NAME                                STATUS    VOLUME   CAPACITY   ACCESS MODES
my-release-wordpress-app-mysql-pvc  Pending                                    
```

**Diagnosis:**
```bash
# Describe PVC
kubectl describe pvc <pvc-name>

# Check storage classes
kubectl get storageclass

# Check PVs
kubectl get pv
```

**Solution:**

**For Minikube:**
```bash
# Enable storage provisioner
minikube addons enable storage-provisioner

# Check default storage class
kubectl get storageclass
```

**Manual PV creation:**
```bash
# Create PV manually if dynamic provisioning not available
kubectl apply -f helm-charts/wordpress-app/templates/pv.yaml
```

---

### Issue: PVC bound but pod still pending

**Symptoms:**
- PVC shows "Bound"
- Pod still in "Pending" state

**Diagnosis:**
```bash
# Check pod events
kubectl describe pod <pod-name>
```

**Common Causes:**
1. Node affinity issues
2. Resource constraints
3. Multiple pods trying to mount RWO volume

**Solution:**
- Use ReadWriteMany access mode
- Check node labels and affinity rules
- Ensure sufficient node resources

---

## Monitoring Issues

### Issue: Prometheus not scraping targets

**Symptoms:**
- Targets show as "DOWN" in Prometheus
- No metrics in Grafana

**Diagnosis:**
```bash
# Port forward to Prometheus
kubectl port-forward svc/monitoring-prometheus-server 9090:80

# Check targets: http://localhost:9090/targets
```

**Solution:**

1. **Check ServiceMonitor**
   ```bash
   kubectl get servicemonitor
   kubectl describe servicemonitor <name>
   ```

2. **Check pod annotations**
   ```bash
   kubectl get pods -o yaml | grep -A 5 annotations
   ```

3. **Verify metrics endpoint**
   ```bash
   # Test metrics endpoint
   kubectl exec -it <nginx-pod> -- curl http://localhost:9145/metrics
   ```

---

### Issue: Grafana cannot connect to Prometheus

**Symptoms:**
- Grafana dashboards show "No data"
- Datasource test fails

**Solution:**

1. **Check Prometheus service**
   ```bash
   kubectl get svc monitoring-prometheus-server
   ```

2. **Verify datasource configuration**
   - Login to Grafana
   - Configuration > Data Sources
   - Test connection
   - URL should be: `http://monitoring-prometheus-server`

3. **Check Grafana logs**
   ```bash
   kubectl logs -l app.kubernetes.io/name=grafana
   ```

---

### Issue: Cannot access Grafana

**Symptoms:**
- Port forward fails
- Cannot login

**Solution:**

1. **Get Grafana password**
   ```bash
   kubectl get secret monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 --decode
   ```

2. **Reset admin password**
   ```bash
   # Edit Grafana deployment
   kubectl edit deployment monitoring-grafana
   
   # Add environment variable:
   # - name: GF_SECURITY_ADMIN_PASSWORD
   #   value: "newpassword"
   ```

3. **Check Grafana pod**
   ```bash
   kubectl get pods -l app.kubernetes.io/name=grafana
   kubectl logs -l app.kubernetes.io/name=grafana
   ```

---

## Performance Issues

### Issue: WordPress slow to respond

**Diagnosis:**
```bash
# Check pod resources
kubectl top pods

# Check logs
kubectl logs -l component=wordpress --tail=100
```

**Solution:**

1. **Increase resources**
   ```yaml
   # Edit values.yaml
   wordpress:
     resources:
       requests:
         memory: "1Gi"
         cpu: "1000m"
       limits:
         memory: "2Gi"
         cpu: "2000m"
   ```

2. **Enable caching**
   - Install Redis
   - Configure WordPress object cache
   - Enable OpCache

3. **Optimize MySQL**
   ```yaml
   # Increase buffer pool size in my.cnf
   innodb_buffer_pool_size = 1G
   ```

---

### Issue: High CPU usage

**Diagnosis:**
```bash
# Check CPU usage
kubectl top pods

# Check which process
kubectl exec -it <pod-name> -- top
```

**Solution:**
1. Scale horizontally
2. Increase resource limits
3. Optimize application code
4. Enable caching

---

## Debugging Commands

### Essential Commands

```bash
# Get all resources
kubectl get all

# Describe resource
kubectl describe <resource-type> <resource-name>

# Get logs
kubectl logs <pod-name>
kubectl logs <pod-name> -c <container-name>
kubectl logs <pod-name> --previous

# Execute command in pod
kubectl exec -it <pod-name> -- /bin/bash
kubectl exec -it <pod-name> -- sh

# Port forward
kubectl port-forward <pod-name> <local-port>:<pod-port>
kubectl port-forward svc/<service-name> <local-port>:<service-port>

# Get events
kubectl get events --sort-by='.lastTimestamp'

# Check resource usage
kubectl top nodes
kubectl top pods

# Get YAML
kubectl get <resource-type> <resource-name> -o yaml

# Edit resource
kubectl edit <resource-type> <resource-name>

# Delete resource
kubectl delete <resource-type> <resource-name>

# Force delete pod
kubectl delete pod <pod-name> --force --grace-period=0
```

### Helm Commands

```bash
# List releases
helm list

# Get values
helm get values <release-name>

# Get manifest
helm get manifest <release-name>

# Rollback
helm rollback <release-name> <revision>

# Upgrade
helm upgrade <release-name> <chart-path>

# Uninstall
helm uninstall <release-name>

# Lint chart
helm lint <chart-path>

# Template chart
helm template <release-name> <chart-path>

# Dry run
helm install <release-name> <chart-path> --dry-run --debug
```

### Docker Commands

```bash
# List images
docker images

# Remove image
docker rmi <image-name>

# Build with no cache
docker build --no-cache -t <tag> <path>

# Check image layers
docker history <image-name>

# Run container for testing
docker run -it <image-name> /bin/bash

# Check container logs
docker logs <container-id>

# Clean up
docker system prune -a
```

---

## Getting Help

### Check Logs

1. **Application logs**
   ```bash
   kubectl logs -l component=nginx --tail=100
   kubectl logs -l component=wordpress --tail=100
   kubectl logs -l component=mysql --tail=100
   ```

2. **Kubernetes events**
   ```bash
   kubectl get events --sort-by='.lastTimestamp' | tail -20
   ```

3. **Describe resources**
   ```bash
   kubectl describe pod <pod-name>
   kubectl describe svc <service-name>
   kubectl describe pvc <pvc-name>
   ```

### Verify Configuration

1. **Check values**
   ```bash
   cat helm-charts/wordpress-app/values.yaml
   ```

2. **Render templates**
   ```bash
   helm template my-release ./helm-charts/wordpress-app
   ```

3. **Validate YAML**
   ```bash
   kubectl apply --dry-run=client -f <file.yaml>
   ```

---

## Still Having Issues?

1. **Check documentation**
   - README.md
   - DEPLOYMENT_GUIDE.md
   - METRICS_DOCUMENTATION.md

2. **Verify prerequisites**
   - Kubernetes cluster running
   - kubectl configured
   - Helm installed
   - Docker running

3. **Start fresh**
   ```bash
   # Clean up everything
   ./scripts/cleanup.sh
   
   # Rebuild images
   ./scripts/build-images.sh
   
   # Redeploy
   ./scripts/deploy.sh
   ```

4. **Test deployment**
   ```bash
   ./scripts/test-deployment.sh
   ```

---

**For additional support, refer to:**
- Kubernetes documentation: https://kubernetes.io/docs/
- Helm documentation: https://helm.sh/docs/
- Docker documentation: https://docs.docker.com/
