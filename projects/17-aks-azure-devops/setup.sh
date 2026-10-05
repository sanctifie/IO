#!/usr/bin/env bash
# Projet 17 — à lancer dans Azure Cloud Shell (Bash). Crée le projet Azure DevOps, le groupe, l'ACR et l'AKS.
# Usage : ORG=https://dev.azure.com/<organisation>/ ./setup.sh
set -euo pipefail
: "${ORG:?ex: ORG=https://dev.azure.com/mon-org/}"
RG=my-aks-rg
LOCATION="${LOCATION:-francecentral}"
ACR="ioacr$RANDOM"
az extension add --name azure-devops --upgrade -y -o none
az devops configure --defaults organization="$ORG"
az devops project show --project k8s-project >/dev/null 2>&1 || az devops project create --name k8s-project -o none
az devops configure --defaults project=k8s-project
az group create --location "$LOCATION" --resource-group "$RG" -o none
az acr create -g "$RG" -n "$ACR" --sku Basic -o none
# Identité managée + rôle AcrPull pour les nœuds (remplace le service principal à mot de passe du tutoriel)
az aks create -g "$RG" -n myakscluster --node-count 1 --node-vm-size Standard_B2s --generate-ssh-keys --attach-acr "$ACR" -o none
az aks get-credentials -g "$RG" -n myakscluster --overwrite-existing
kubectl get nodes
echo "ACR : $ACR.azurecr.io — crée maintenant le pipeline (Pipelines → New pipeline → GitHub → Deploy to AKS)."
echo "Nettoyage : az group delete -n $RG --yes --no-wait"
