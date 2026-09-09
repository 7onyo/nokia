#!/bin/bash
set -euo pipefail

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'
SEP=$(printf -- '-%.0s' {1..60})

echo -e "\n${CYAN}Running Kubernetes Cleanup${NC}"
echo -e "${GREEN}${SEP}${NC}"

kubectl delete configmap web-demo-html --ignore-not-found=true
kubectl delete deployment web-demo --ignore-not-found=true
kubectl delete svc web-demo --ignore-not-found=true


if [[ "${1:-}" == "--full" ]]; then
    echo -e "\n${CYAN}Performing Full Minikube & Docker Teardown${NC}"
    echo -e "${GREEN}${SEP}${NC}"
    
    minikube delete --all
    
    docker rm -f minikube 2>/dev/null || true
    
    docker rmi -f $(docker images -q gcr.io/k8s-minikube/kicbase) 2>/dev/null || true
    
    docker system prune -f
fi

echo -e "\n${GREEN}Cleanup complete!${NC}"
