# Projet 07 — Parcours Azure DevOps (AKS, ACR, Key Vault)

> Partie 2 — CI/CD · Bible : chapitre « Projet 07 » de `docs/Bible-DevOps-Cloud.pdf`

## Objectif

Pipeline Azure DevOps qui crée l'infra (Terraform azurerm v4), construit une app .NET 8 et la déploie sur AKS.

## Ce que contient ce dossier

```text
azure-pipelines.yml
app/.dockerignore
app/Dockerfile
app/Program.cs
app/Startup.cs
app/appsettings.Development.json
app/appsettings.json
app/aspnet-core-dotnet-core.csproj
app/bundleconfig.json
app/Pages/About.cshtml
app/Pages/About.cshtml.cs
app/Pages/Contact.cshtml
app/Pages/Contact.cshtml.cs
app/Pages/Error.cshtml
app/Pages/Error.cshtml.cs
app/Pages/Index.cshtml
app/Pages/Index.cshtml.cs
app/Pages/Privacy.cshtml
app/Pages/Privacy.cshtml.cs
app/Pages/_ViewImports.cshtml
app/Pages/_ViewStart.cshtml
app/Pages/Shared/_CookieConsentPartial.cshtml
app/Pages/Shared/_Layout.cshtml
app/Pages/Shared/_ValidationScriptsPartial.cshtml
app/charts/sampleapp/.helmignore
app/charts/sampleapp/Chart.yaml
app/charts/sampleapp/values.yaml
inspec/inspec.yml
inspec/controls/infra.rb
k8s/aspnet.yaml
setup/01-state-storage.sh
setup/02-aks-admin-group.sh
setup/03-pipeline-rbac.sh
terraform/main.tf
terraform/outputs.tf
terraform/production.tfvars.example
terraform/providers.tf
terraform/variables.tf
vars/production.tfvars.example
```

_Le code source de l'application (dossiers `src/`, `public/`, etc.) n'est pas listé._

## Corrections apportées au code d'origine

- azurerm v4 (rbac_authorization_enabled…), ACR sans compte admin, AcrPull pour AKS
- Admin AKS via un groupe Entra ID
- Environnement infra-production avec approbation
- App .NET 8 (ASPNETCORE_URLS)

## Ce qui a été vérifié avant livraison

- terraform validate
- Image .NET construite et testée
- shellcheck des scripts setup/

## À personnaliser avant de lancer

Valeurs d'exemple à remplacer par les tiennes (pseudo, compte, IP, bucket…) :

- `azure-pipelines.yml` : lignes 22, 40

Et toujours : ta région (`eu-west-3` / `francecentral` par défaut), tes noms uniques (buckets, registres), tes secrets **uniquement** dans les credentials / variables secrètes, jamais dans Git.

## Checklist (étapes de la bible)

- [ ] Lab 1 — Mise en place initiale
- [ ] Lab 2 — Déployer l'infrastructure avec Terraform via Azure DevOps
- [ ] Lab 3 — Construire l'application et la pousser dans ACR
- [ ] Lab 4 — Déployer dans AKS
- [ ] Lab 5 — Le vrai CI/CD : déclenchement automatique
- [ ] Lab 6 — Tester l'infrastructure avec InSpec
- [ ] Lab 7 — Monitoring et alertes
- [ ] Captures d'écran des résultats (pipeline vert, application, tableaux de bord)
- [ ] Nettoyage effectué et vérifié dans la console (voir ci-dessous)

## Nettoyage

az group delete sur le groupe de l'application ET celui de l'état Terraform ; supprimer la service connection.

## Mon journal

| Date | Ce que j'ai fait | Problème rencontré | Solution |
|---|---|---|---|
| | | | |

### Ce que je retiens / questions d'entretien

- 
