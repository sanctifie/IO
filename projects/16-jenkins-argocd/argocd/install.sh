#!/usr/bin/env bash
# Projet 16 — installe Argo CD et sa CLI, affiche le mot de passe initial.
set -euo pipefail
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl -n argocd rollout status deploy/argocd-server --timeout=300s
if ! command -v argocd >/dev/null; then
  curl -sSLo /tmp/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
  sudo install -m 555 /tmp/argocd /usr/local/bin/argocd
fi
echo "Mot de passe admin : $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)"
echo "Accès : kubectl -n argocd port-forward svc/argocd-server 8443:443  → https://localhost:8443"
echo "(ou : kubectl patch svc argocd-server -n argocd -p '{\"spec\":{\"type\":\"LoadBalancer\"}}' — payant)"
