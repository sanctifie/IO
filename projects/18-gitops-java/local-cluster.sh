#!/usr/bin/env bash
# Projet 18 — cluster local kind + Argo CD + Application (sur ton poste, gratuit).
set -euo pipefail
cd "$(dirname "$0")"
kind get clusters | grep -qx gitops || kind create cluster --name gitops
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl -n argocd rollout status deploy/argocd-server --timeout=300s
kubectl apply -f argocd/application.yaml
echo "Mot de passe Argo CD : $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)"
echo "Argo CD : kubectl -n argocd port-forward svc/argocd-server 8443:443"
echo "Appli   : kubectl port-forward svc/spring-boot-app-service 8080:80"
echo "Nettoyage : kind delete cluster --name gitops"
