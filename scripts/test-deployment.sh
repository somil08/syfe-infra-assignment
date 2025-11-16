#!/bin/bash
# Test WordPress deployment
# Author: Somil Rathore

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}=========================================="
echo "Testing WordPress Deployment"
echo "==========================================${NC}"
echo ""

FAILED_TESTS=0
PASSED_TESTS=0

# Test function
test_check() {
    local test_name=$1
    local test_command=$2
    
    echo -e "${BLUE}Testing: ${test_name}${NC}"
    if eval "$test_command" &> /dev/null; then
        echo -e "${GREEN}✓ PASSED${NC}"
        ((PASSED_TESTS++))
    else
        echo -e "${RED}✗ FAILED${NC}"
        ((FAILED_TESTS++))
    fi
    echo ""
}

# Test 1: Check if all pods are running
echo -e "${YELLOW}[1/10] Checking pod status...${NC}"
test_check "MySQL pod running" "kubectl get pods -l component=mysql -o jsonpath='{.items[0].status.phase}' | grep -q Running"
test_check "WordPress pod running" "kubectl get pods -l component=wordpress -o jsonpath='{.items[0].status.phase}' | grep -q Running"
test_check "Nginx pod running" "kubectl get pods -l component=nginx -o jsonpath='{.items[0].status.phase}' | grep -q Running"

# Test 2: Check if services exist
echo -e "${YELLOW}[2/10] Checking services...${NC}"
test_check "MySQL service exists" "kubectl get svc mysql-service"
test_check "WordPress service exists" "kubectl get svc wordpress-service"
test_check "Nginx service exists" "kubectl get svc nginx-service"

# Test 3: Check PVCs
echo -e "${YELLOW}[3/10] Checking PersistentVolumeClaims...${NC}"
test_check "MySQL PVC bound" "kubectl get pvc -l component=mysql -o jsonpath='{.items[0].status.phase}' | grep -q Bound"
test_check "WordPress PVC bound" "kubectl get pvc -l component=wordpress -o jsonpath='{.items[0].status.phase}' | grep -q Bound"

# Test 4: Check monitoring pods
echo -e "${YELLOW}[4/10] Checking monitoring stack...${NC}"
test_check "Prometheus pod running" "kubectl get pods -l app.kubernetes.io/name=prometheus -o jsonpath='{.items[0].status.phase}' | grep -q Running"
test_check "Grafana pod running" "kubectl get pods -l app.kubernetes.io/name=grafana -o jsonpath='{.items[0].status.phase}' | grep -q Running"

# Test 5: Check if WordPress is accessible
echo -e "${YELLOW}[5/10] Testing WordPress accessibility...${NC}"
NGINX_POD=$(kubectl get pod -l component=nginx -o jsonpath='{.items[0].metadata.name}')
test_check "WordPress responds" "kubectl exec $NGINX_POD -- curl -s -o /dev/null -w '%{http_code}' http://localhost | grep -q 200"

# Test 6: Check MySQL connectivity
echo -e "${YELLOW}[6/10] Testing MySQL connectivity...${NC}"
MYSQL_POD=$(kubectl get pod -l component=mysql -o jsonpath='{.items[0].metadata.name}')
test_check "MySQL is accessible" "kubectl exec $MYSQL_POD -- mysqladmin ping -h localhost -u root -prootpassword123"

# Test 7: Check Nginx metrics endpoint
echo -e "${YELLOW}[7/10] Testing Nginx metrics...${NC}"
test_check "Nginx metrics endpoint" "kubectl exec $NGINX_POD -- curl -s http://localhost:9145/metrics | grep -q nginx_http_requests_total"

# Test 8: Check Prometheus targets
echo -e "${YELLOW}[8/10] Testing Prometheus...${NC}"
PROM_POD=$(kubectl get pod -l app.kubernetes.io/name=prometheus -o jsonpath='{.items[0].metadata.name}')
test_check "Prometheus is running" "kubectl exec $PROM_POD -c prometheus-server -- wget -q -O- http://localhost:9090/-/healthy | grep -q Prometheus"

# Test 9: Check Grafana
echo -e "${YELLOW}[9/10] Testing Grafana...${NC}"
GRAFANA_POD=$(kubectl get pod -l app.kubernetes.io/name=grafana -o jsonpath='{.items[0].metadata.name}')
test_check "Grafana is running" "kubectl exec $GRAFANA_POD -- curl -s http://localhost:3000/api/health | grep -q ok"

# Test 10: Generate traffic and verify metrics
echo -e "${YELLOW}[10/10] Testing metrics collection...${NC}"
echo "Generating test traffic..."
for i in {1..10}; do
    kubectl exec $NGINX_POD -- curl -s http://localhost > /dev/null 2>&1 || true
done
sleep 5
test_check "Metrics are being collected" "kubectl exec $NGINX_POD -- curl -s http://localhost:9145/metrics | grep nginx_http_requests_total | grep -v '#' | awk '{print \$2}' | awk '{if(\$1>0) exit 0; else exit 1}'"

# Summary
echo -e "${BLUE}=========================================="
echo "Test Summary"
echo "==========================================${NC}"
echo ""
echo -e "${GREEN}Passed: ${PASSED_TESTS}${NC}"
echo -e "${RED}Failed: ${FAILED_TESTS}${NC}"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}=========================================="
    echo "All tests passed! ✓"
    echo "==========================================${NC}"
    exit 0
else
    echo -e "${RED}=========================================="
    echo "Some tests failed! ✗"
    echo "==========================================${NC}"
    echo ""
    echo "Check the logs for more details:"
    echo "  kubectl logs -l component=nginx"
    echo "  kubectl logs -l component=wordpress"
    echo "  kubectl logs -l component=mysql"
    exit 1
fi
