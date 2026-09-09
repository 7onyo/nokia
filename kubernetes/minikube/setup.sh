#!/bin/bash
set -euo pipefail

GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'
SEP=$(printf -- '-%.0s' {1..60})

echo -e "\n${CYAN}Starting Minikube Demo Setup${NC}"
echo -e "${GREEN}${SEP}${NC}"

if [[ ! -f "index.html" ]]; then
    echo "Error: index.html not found in the current directory."
    echo "Please ensure the custom HTML file exists before running this script."
    exit 1
fi

echo -e "\n${CYAN}1. Ensuring Minikube is running${NC}"
echo -e "${GREEN}${SEP}${NC}"
minikube start --driver=docker

echo -e "\n${CYAN}2. Cleaning up any old resources${NC}"
echo -e "${GREEN}${SEP}${NC}"
bash cleanup.sh

echo -e "\n${CYAN}3. Creating ConfigMap from index.html${NC}"
echo -e "${GREEN}${SEP}${NC}"
kubectl create configmap web-demo-html --from-file=index.html

echo -e "\n${CYAN}4. Creating NGINX deployment with mounted HTML ConfigMap${NC}"
echo -e "${GREEN}${SEP}${NC}"
kubectl apply -f deployment.yaml

echo -e "\n${CYAN}5. Exposing deployment as a NodePort service${NC}"
echo -e "${GREEN}${SEP}${NC}"
kubectl expose deployment web-demo --type=NodePort --port=80

echo -e "\n${CYAN}6. Waiting for the deployment rollout to complete${NC}"
echo -e "${GREEN}${SEP}${NC}"
kubectl rollout status deployment/web-demo --timeout=90s

echo -e "\n${CYAN}7. Setup Complete! Cluster Information:${NC}"
echo -e "${GREEN}${SEP}${NC}"
kubectl get svc web-demo
echo ""
kubectl get pods -o wide
echo -e "\nRetrieving the Minikube service URL"
minikube service web-demo --url
