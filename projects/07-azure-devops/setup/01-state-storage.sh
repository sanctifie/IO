#!/usr/bin/env bash
# Projet 07, lab 1.3 — stockage de l'état Terraform (Azure CLI connectée : az login)
set -euo pipefail
RG=devops-journey-rg
LOCATION="${LOCATION:-francecentral}"
SA="devopsjourney$RANDOM"
az group create -l "$LOCATION" -n "$RG" -o none
az storage account create -n "$SA" -g "$RG" -l "$LOCATION" --sku Standard_LRS --min-tls-version TLS1_2 -o none
az role assignment create --assignee "$(az ad signed-in-user show --query id -o tsv)" --role "Storage Blob Data Contributor" \
  --scope "$(az storage account show -n "$SA" -g "$RG" --query id -o tsv)" -o none
sleep 30   # propagation du rôle
az storage container create --name tfstate --account-name "$SA" --auth-mode login -o none
echo "Storage account : $SA  → à mettre dans azure-pipelines.yml (backendAzureRmStorageAccountName)"
