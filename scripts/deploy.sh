#!/bin/bash
# Deploy WordPress application and monitoring stack
# Author: Somil Rathore

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}=========================================="
echo "Deploying WordPress on Kubernetes"
echo "==========================================${NC}"
echo ""

# Check prerequisites
echo -e "${BLUE}Checking prerequisites...${NC}"

if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}✗ kubectl not found${NC}"
    exit 1
fi
echo -e "${GREEN}✓ kubectl found${NC}"

if ! command -v helm &> /dev/null; then
    echo -e "${RED}✗ helm not found${NC}"
    exit 1
fi
echo -e "${GREEN}✓ helm found${NC}"

if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}✗ Cannot connect to Kubernetes cluster${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Kubernetes cluster accessible${NC}"
echo ""

# Deploy WordPress application
echo -e "${BLUE}[1/2] Deploying WordPress application...${NC}"
helm install my-release "${PROJECT_DIR}/helm-charts/wordpress-app"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ WordPress application deployed${NC}"
else
    echo -e "${RED}✗ Failed to deploy WordPress application${NC}"
    exit 1
fi
echo ""

# Wait for WordPress pods
echo -e "${YELLOW}Waiting for WordPress pods to be ready...${NC}"
kubectl wait --for=condition=ready pod -l component=mysql --timeout=300s
kubectl wait --for=condition=ready pod -l component=wordpress --timeout=300s
kubectl wait --for=condition=ready pod -l component=nginx --timeout=300s
echo -e "${GREEN}✓ All WordPress pods are ready${NC}"
echo ""

# Add Helm repositories for monitoring
echo -e "${BLUE}Adding Helm repositories...${NC}"
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
echo -e "${GREEN}✓ Helm repositories added${NC}"
echo ""

# Update monitoring chart dependencies
echo -e "${BLUE}Updating monitoring chart dependencies...${NC}"
cd "${PROJECT_DIR}/helm-charts/monitoring"
helm dependency update
cd "${PROJECT_DIR}"
echo -e "${GREEN}✓ Dependencies updated${NC}"
echo ""

# Deploy monitoring stack
echo -e "${BLUE}[2/2] Deploying monitoring stack...${NC}"
helm install monitoring "${PROJECT_DIR}/helm-charts/monitoring"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Monitoring stack deployed${NC}"
else
    echo -e "${RED}✗ Failed to deploy monitoring stack${NC}"
    exit 1
fi
echo ""

# Wait for monitoring pods
echo -e "${YELLOW}Waiting for monitoring pods to be ready...${NC}"
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=prometheus --timeout=300s
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=grafana --timeout=300s
echo -e "${GREEN}✓ All monitoring pods are ready${NC}"
echo ""

# Display status
echo -e "${BLUE}=========================================="
echo "Deployment Status"
echo "==========================================${NC}"
echo ""

echo -e "${BLUE}Pods:${NC}"
kubectl get pods
echo ""

echo -e "${BLUE}Services:${NC}"
kubectl get svc
echo ""

echo -e "${BLUE}PersistentVolumeClaims:${NC}"
kubectl get pvc
echo ""

# Get Grafana password
GRAFANA_PASSWORD=$(kubectl get secret monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 --decode)

echo -e "${GREEN}=========================================="
echo "Deployment Complete!"
echo "==========================================${NC}"
echo ""
echo -e "${YELLOW}Access your applications:${NC}"
echo ""
echo -e "${BLUE}WordPress:${NC}"
echo "  kubectl port-forward svc/nginx-service 8080:80"
echo "  http://localhost:8080"
echo ""
echo -e "${BLUE}Grafana:${NC}"
echo "  kubectl port-forward svc/monitoring-grafana 3000:80"
echo "  http://localhost:3000"
echo "  Username: admin"
echo "  Password: ${GRAFANA_PASSWORD}"
echo ""
echo -e "${BLUE}Prometheus:${NC}"
echo "  kubectl port-forward svc/monitoring-prometheus-server 9090:80"
echo "  http://localhost:9090"
echo ""
echo -e "${BLUE}Nginx Metrics:${NC}"
echo "  kubectl port-forward svc/nginx-service 9145:9145"
echo "  http://localhost:9145/metrics"
echo ""
