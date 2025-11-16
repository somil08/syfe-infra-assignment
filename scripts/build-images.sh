#!/bin/bash
# Build all Docker images for WordPress on Kubernetes
# Author: Somil Rathore

set -e

echo "=========================================="
echo "Building Docker Images for WordPress K8s"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}Project directory: ${PROJECT_DIR}${NC}"
echo ""

# Build Nginx (OpenResty)
echo -e "${BLUE}[1/3] Building Nginx (OpenResty) image...${NC}"
docker build -t wordpress-nginx:latest "${PROJECT_DIR}/docker/nginx"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Nginx image built successfully${NC}"
else
    echo -e "${RED}✗ Failed to build Nginx image${NC}"
    exit 1
fi
echo ""

# Build WordPress
echo -e "${BLUE}[2/3] Building WordPress image...${NC}"
docker build -t wordpress-custom:latest "${PROJECT_DIR}/docker/wordpress"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ WordPress image built successfully${NC}"
else
    echo -e "${RED}✗ Failed to build WordPress image${NC}"
    exit 1
fi
echo ""

# Build MySQL
echo -e "${BLUE}[3/3] Building MySQL image...${NC}"
docker build -t mysql-custom:latest "${PROJECT_DIR}/docker/mysql"
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ MySQL image built successfully${NC}"
else
    echo -e "${RED}✗ Failed to build MySQL image${NC}"
    exit 1
fi
echo ""

# List built images
echo -e "${BLUE}Built images:${NC}"
docker images | grep -E "wordpress-nginx|wordpress-custom|mysql-custom"
echo ""

# Check if running in Minikube
if command -v minikube &> /dev/null; then
    read -p "Load images to Minikube? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Loading images to Minikube...${NC}"
        minikube image load wordpress-nginx:latest
        minikube image load wordpress-custom:latest
        minikube image load mysql-custom:latest
        echo -e "${GREEN}✓ Images loaded to Minikube${NC}"
    fi
fi

echo ""
echo -e "${GREEN}=========================================="
echo "All images built successfully!"
echo "==========================================${NC}"
