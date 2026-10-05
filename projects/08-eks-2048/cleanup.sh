#!/usr/bin/env bash
# Projet 08 — ORDRE IMPORTANT : d'abord le Service (load balancer), ensuite le cluster.
set -uo pipefail
cd "$(dirname "$0")" || exit 1
kubectl delete -f k8s/mygame-svc.yaml --ignore-not-found
kubectl delete -f k8s/2048-deploy.yaml -f k8s/2048-pod.yaml --ignore-not-found
eksctl delete cluster -f eks/cluster.yaml --wait
echo "Vérifie EC2 → Load Balancers et CloudFormation : plus rien ne doit rester."
