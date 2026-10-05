#!/usr/bin/env bash
# Projet 07, lab 1.4 — groupe Entra des administrateurs AKS, avec l'utilisateur courant comme membre
set -euo pipefail
G=devopsthehardway-aks-group
az ad group show --group "$G" >/dev/null 2>&1 || az ad group create --display-name "$G" --mail-nickname "$G" -o none
az ad group member add --group "$G" --member-id "$(az ad signed-in-user show --query id -o tsv)" 2>/dev/null || true
echo "aks_admin_group_object_id = \"$(az ad group show --group "$G" --query id -o tsv)\"  → vars/production.tfvars"
