#!/usr/bin/env bash
# Projet 15 — l'ordre compte : Ingress (ALB) → application + volumes → contrôleur → cluster
set -uo pipefail
CLUSTER="${CLUSTER:-io-robotshop}"; REGION="${REGION:-eu-west-3}"
cd "$(dirname "$0")" || exit 1
kubectl delete -f ingress.yaml --ignore-not-found
helm uninstall robot-shop -n robot-shop
kubectl delete pvc --all -n robot-shop
helm uninstall aws-load-balancer-controller -n kube-system
eksctl delete cluster --name "$CLUSTER" --region "$REGION" --wait
echo "Vérifie EC2 → Load Balancers et Volumes (aucun volume 'available' orphelin)."
