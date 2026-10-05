#!/usr/bin/env bash
# Projet 08 — cluster eksctl + jeu 2048 ; affiche l'URL du load balancer.
set -euo pipefail
cd "$(dirname "$0")"
eksctl create cluster -f eks/cluster.yaml
kubectl apply -f k8s/2048-deploy.yaml -f k8s/mygame-svc.yaml
kubectl rollout status deploy/game-2048 --timeout=180s
echo "Attente de l'adresse du load balancer..."
until H=$(kubectl get svc mygame-svc -o jsonpath='{.status.loadBalancer.ingress[0].hostname}') && [ -n "$H" ]; do sleep 10; done
echo "Jeu : http://$H  (2 à 3 minutes de propagation DNS)"
