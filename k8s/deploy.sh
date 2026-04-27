#!/bin/bash
set -e

echo "========================================="
echo " Guestbook EKS Deployment"
echo "========================================="

# Variables - UPDATE THESE
AWS_ACCOUNT_ID="<account-id>"
AWS_REGION="<region>"
ECR_BASE="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

# Login to ECR
echo "[1/6] Logging into ECR..."
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_BASE}

# Create ECR repos (ignore if exists)
echo "[2/6] Creating ECR repositories..."
for repo in guestbook-db guestbook-api guestbook-ui; do
  aws ecr create-repository --repository-name ${repo} --region ${AWS_REGION} 2>/dev/null || true
done

# Build and push images
echo "[3/6] Building and pushing Docker images..."
cd "$(dirname "$0")/.."

docker build -t ${ECR_BASE}/guestbook-db:latest  ./guest-book-backend
docker build -t ${ECR_BASE}/guestbook-api:latest ./guest-book-api
docker build -t ${ECR_BASE}/guestbook-ui:latest  ./guest-book-ui

docker push ${ECR_BASE}/guestbook-db:latest
docker push ${ECR_BASE}/guestbook-api:latest
docker push ${ECR_BASE}/guestbook-ui:latest

# Update image references in manifests
echo "[4/6] Updating image references in manifests..."
find ./k8s -name "*.yaml" -exec sed -i "s|<account-id>|${AWS_ACCOUNT_ID}|g" {} \;
find ./k8s -name "*.yaml" -exec sed -i "s|<region>|${AWS_REGION}|g" {} \;

# Deploy to EKS
echo "[5/6] Deploying to EKS..."
kubectl apply -f ./k8s/base/namespaces.yaml

kubectl apply -f ./k8s/db/
kubectl apply -f ./k8s/base/network-policies.yaml

echo "Waiting for MySQL to be ready..."
kubectl wait --for=condition=ready pod -l app=mysql -n guestbook-db --timeout=120s

kubectl apply -f ./k8s/api/
echo "Waiting for API to be ready..."
kubectl wait --for=condition=ready pod -l app=guestbook-api -n guestbook-api --timeout=120s

kubectl apply -f ./k8s/ui/

# Get LB URL
echo "[6/6] Deployment complete!"
echo "========================================="
echo "Waiting for LoadBalancer URL..."
sleep 10
LB_URL=$(kubectl get svc guestbook-ui -n guestbook-ui -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
echo "Access the app at: http://${LB_URL}"
echo "========================================="
