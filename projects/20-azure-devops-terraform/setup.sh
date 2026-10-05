#!/usr/bin/env bash
# Projet 20 — étapes 1 et 2 : identité de déploiement, stockage de l'état et rôles.
# Usage : ./setup.sh   (az login au préalable)
set -euo pipefail

LOCATION="${LOCATION:-francecentral}"
STATE_RG="tfstate-tfdemo-rg"
STATE_SA="${STATE_SA:-tfstatetfdemo$RANDOM}"   # nom unique, 3-24 caractères, minuscules et chiffres
SPN_NAME="tfdemo-spn"

SUB="$(az account show --query id -o tsv)"
TENANT="$(az account show --query tenantId -o tsv)"

az group create -n "$STATE_RG" -l "$LOCATION" -o none
az storage account create -n "$STATE_SA" -g "$STATE_RG" -l "$LOCATION" --sku Standard_LRS \
  --min-tls-version TLS1_2 --allow-blob-public-access false -o none
SA_ID="$(az storage account show -n "$STATE_SA" -g "$STATE_RG" --query id -o tsv)"

# L'utilisateur courant doit lui aussi pouvoir créer le conteneur avec --auth-mode login
ME="$(az ad signed-in-user show --query id -o tsv)"
az role assignment create --assignee "$ME" --role "Storage Blob Data Contributor" --scope "$SA_ID" -o none || true
echo "Attente de la propagation du rôle (60 s)…"; sleep 60
az storage container create --name tfstate --account-name "$STATE_SA" --auth-mode login -o none

# App registration + service principal + secret (affiché une seule fois)
APP_ID="$(az ad app create --display-name "$SPN_NAME" --query appId -o tsv)"
az ad sp create --id "$APP_ID" -o none
SECRET="$(az ad app credential reset --id "$APP_ID" --display-name ADO --years 1 --query password -o tsv)"

az role assignment create --assignee "$APP_ID" --role "Storage Blob Data Contributor" --scope "$SA_ID" -o none
az role assignment create --assignee "$APP_ID" --role "Contributor" --scope "/subscriptions/$SUB" -o none

cat <<INFO

=== À reporter dans le variable group Azure DevOps « Terraform_SPN » ===
ARM_CLIENT_ID       = $APP_ID
ARM_TENANT_ID       = $TENANT
ARM_SUBSCRIPTION_ID = $SUB
ARM_CLIENT_SECRET   = (affiché ci-dessous, à cocher comme SECRET puis à effacer de ton terminal)
$SECRET

=== À reporter dans terraform/providers.tf ===
storage_account_name = "$STATE_SA"
INFO
