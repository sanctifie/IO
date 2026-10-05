#!/usr/bin/env bash
# Projet 07, lab 1.2 — donne à l'identité de la service connection le droit d'attribuer des rôles (AcrPull, Key Vault).
# Usage : SP_OBJECT_ID=<object id du service principal de la service connection> ./03-pipeline-rbac.sh
set -euo pipefail
: "${SP_OBJECT_ID:?SP_OBJECT_ID manquant (Project settings > Service connections > Manage service principal)}"
SUB=$(az account show --query id -o tsv)
az role assignment create --assignee-object-id "$SP_OBJECT_ID" --assignee-principal-type ServicePrincipal \
  --role "Role Based Access Control Administrator" --scope "/subscriptions/$SUB" -o none
echo "OK"
