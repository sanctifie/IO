#!/usr/bin/env bash
# Projet 10 — crée la Web App Linux (plan F1 gratuit) et Application Insights. Nettoyage : az group delete -n io-dotnet-rg
set -euo pipefail
RG=io-dotnet-rg
LOCATION="${LOCATION:-francecentral}"
APP="io-dotnet-$RANDOM"
SKU="${SKU:-F1}"
az group create -n "$RG" -l "$LOCATION" -o none
az appservice plan create -n io-dotnet-plan -g "$RG" --is-linux --sku "$SKU" -o none
az webapp create -n "$APP" -g "$RG" -p io-dotnet-plan --runtime "DOTNETCORE:8.0" -o none
az extension add --name application-insights --upgrade -y -o none
az monitor app-insights component create --app "$APP-ai" -g "$RG" -l "$LOCATION" --kind web -o none
CONN=$(az monitor app-insights component show --app "$APP-ai" -g "$RG" --query connectionString -o tsv)
az webapp config appsettings set -n "$APP" -g "$RG" --settings APPLICATIONINSIGHTS_CONNECTION_STRING="$CONN" -o none
echo "Web App : $APP  → https://$APP.azurewebsites.net  (mettre le nom dans webAppName de azure-pipelines.yml)"
