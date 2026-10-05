#!/usr/bin/env bash
# Projet 04 — construit l'image et la pousse dans ECR.  Usage : ./push-ecr.sh v1
set -euo pipefail
TAG="${1:-v1}"
REGION="${AWS_REGION:-eu-west-3}"
REPO=hello-world-django-app
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGISTRY="$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com"

aws ecr describe-repositories --repository-names "$REPO" --region "$REGION" >/dev/null 2>&1 \
  || aws ecr create-repository --repository-name "$REPO" --image-scanning-configuration scanOnPush=true --region "$REGION" >/dev/null
aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "$REGISTRY"
# --platform : indispensable sur Mac Apple Silicon (Fargate tourne en x86_64 par défaut)
docker build --platform linux/amd64 -t "$REGISTRY/$REPO:$TAG" "$(dirname "$0")/../app"
docker push "$REGISTRY/$REPO:$TAG"
echo "Image : $REGISTRY/$REPO:$TAG"
