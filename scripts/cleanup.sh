#!/bin/bash
# Cleanup WordPress deployment
# Author: Somil Rathore

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${RED}=========================================="
echo "Cleanup WordPress Deployment"
echo "==========================================${NC}"
echo ""

echo -e "${YELLOW}WARNING: This will delete all WordPress data!${NC}"
read -p "Are you sure you want to continue? (yes/no) " -r
echo
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Cleanup cancelled."
    exit 0
fi

# Delete WordPress application
echo -e "${BLUE}[1/3] Deleting WordPress application...${NC}"
if helm list | grep -q "my-release"; then
    helm delete my-release
    echo -e "${GREEN}✓ WordPress application deleted${NC}"
else
    echo -e "${YELLOW}⚠ WordPress application not found${NC}"
fi
echo ""

# Delete monitoring stack
echo -e "${BLUE}[2/3] Deleting monitoring stack...${NC}"
if helm list | grep -q "monitoring"; then
    helm delete monitoring
    echo -e "${GREEN}✓ Monitoring stack deleted${NC}"
else
    echo -e "${YELLOW}⚠ Monitoring stack not found${NC}"
fi
echo ""

# Wait for pods to terminate
echo -e "${YELLOW}Waiting for pods to terminate...${NC}"
sleep 10

# Delete PVCs
echo -e "${BLUE}[3/3] Deleting PersistentVolumeClaims...${NC}"
kubectl delete pvc --all --timeout=60s
echo -e "${GREEN}✓ PVCs deleted${NC}"
echo ""

# Delete PVs (if any remain)
echo -e "${BLUE}Checking for remaining PersistentVolumes...${NC}"
if kubectl get pv | grep -q "my-release"; then
    kubectl delete pv --all
    echo -e "${GREEN}✓ PVs deleted${NC}"
else
    echo -e "${YELLOW}⚠ No PVs to delete${NC}"
fi
echo ""

# Verify cleanup
echo -e "${BLUE}Verifying cleanup...${NC}"
echo ""

echo -e "${BLUE}Remaining pods:${NC}"
kubectl get pods
echo ""

echo -e "${BLUE}Remaining services:${NC}"
kubectl get svc
echo ""

echo -e "${BLUE}Remaining PVCs:${NC}"
kubectl get pvc
echo ""

echo -e "${GREEN}=========================================="
echo "Cleanup Complete!"
echo "==========================================${NC}"
echo ""
echo -e "${YELLOW}Note: If using Minikube, you can delete the cluster with:${NC}"
echo "  minikube delete"
echo ""
