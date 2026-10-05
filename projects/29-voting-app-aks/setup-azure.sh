#!/usr/bin/env bash
# Projet 29 — étapes 3, 7 et 8 : ACR, AKS (avec droit de tirer les images d'ACR) et Argo CD.
# Usage : ./setup-azure.sh   (az login au préalable)
set -euo pipefail
RG="${RG:-voting-rg}"
LOCATION="${LOCATION:-francecentral}"
ACR="${ACR:-votingacr$RANDOM}"   # nom unique, minuscules et chiffres
AKS="${AKS:-voting-aks}"

az group create -n "$RG" -l "$LOCATION" -o none
az acr create -g "$RG" -n "$ACR" --sku Basic -o none
echo "ACR : $ACR.azurecr.io   (à reporter dans les 3 azure-pipelines-*.yml : containerRegistry)"

# --attach-acr : rôle AcrPull pour les nœuds → aucun imagePullSecret à gérer
az aks create -g "$RG" -n "$AKS" --node-count 1 --node-vm-size Standard_B2s \
  --generate-ssh-keys --attach-acr "$ACR" -o none
az aks get-credentials -g "$RG" -n "$AKS" --overwrite-existing
kubectl get nodes

kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd --server-side -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait --for=condition=Ready pods --all -n argocd --timeout=600s
echo "Mot de passe admin Argo CD :"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
echo "Interface : kubectl -n argocd port-forward svc/argocd-server 8443:443  →  https://localhost:8443"
echo "Nettoyage : az group delete -n $RG --yes --no-wait"
