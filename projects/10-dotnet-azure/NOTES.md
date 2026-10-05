# Projet 10 — .NET sur Azure App Service

> Partie 2 — CI/CD · Bible : chapitre « Projet 10 » de `docs/Bible-DevOps-Cloud.pdf`

## Objectif

Pipeline Azure DevOps : build, tests unitaires et déploiement d'une application ASP.NET Core sur App Service.

## Ce que contient ce dossier

```text
.gitignore
IoDotnet.sln
azure-pipelines.yml
infra.sh
IoDotnet.Tests/GreetingTests.cs
IoDotnet.Tests/IoDotnet.Tests.csproj
IoDotnet.Web/IoDotnet.Web.csproj
IoDotnet.Web/Program.cs
IoDotnet.Web/appsettings.Development.json
IoDotnet.Web/appsettings.json
IoDotnet.Web/Pages/Error.cshtml
IoDotnet.Web/Pages/Error.cshtml.cs
IoDotnet.Web/Pages/Index.cshtml
IoDotnet.Web/Pages/Index.cshtml.cs
IoDotnet.Web/Pages/Privacy.cshtml
IoDotnet.Web/Pages/Privacy.cshtml.cs
IoDotnet.Web/Pages/_ViewImports.cshtml
IoDotnet.Web/Pages/_ViewStart.cshtml
IoDotnet.Web/Pages/Shared/_Layout.cshtml
IoDotnet.Web/Pages/Shared/_Layout.cshtml.css
IoDotnet.Web/Pages/Shared/_ValidationScriptsPartial.cshtml
IoDotnet.Web/Properties/launchSettings.json
IoDotnet.Web/Services/Greeting.cs
```

_Le code source de l'application (dossiers `src/`, `public/`, etc.) n'est pas listé._

## Corrections apportées au code d'origine

- Solution générée proprement : projet Web + projet de tests xUnit
- Logique testable isolée (Services/Greeting.cs)

## Ce qui a été vérifié avant livraison

- dotnet test : 2 tests réussis
- shellcheck de infra.sh

## À personnaliser avant de lancer

Valeurs d'exemple à remplacer par les tiennes (pseudo, compte, IP, bucket…) :

- `azure-pipelines.yml` : ligne 12

Et toujours : ta région (`eu-west-3` / `francecentral` par défaut), tes noms uniques (buckets, registres), tes secrets **uniquement** dans les credentials / variables secrètes, jamais dans Git.

## Checklist (étapes de la bible)

- [ ] Étape 1 — Créer l'application .NET
- [ ] Étape 2 — Créer la Web App et Application Insights
- [ ] Étape 3 — Le pipeline multi-stages
- [ ] Étape 4 — Examiner ce que fait le pipeline
- [ ] Étape 5 — Commit et livraison continue
- [ ] Étape 6 — Application Insights
- [ ] Captures d'écran des résultats (pipeline vert, application, tableaux de bord)
- [ ] Nettoyage effectué et vérifié dans la console (voir ci-dessous)

## Nettoyage

az group delete du groupe de ressources.

## Mon journal

| Date | Ce que j'ai fait | Problème rencontré | Solution |
|---|---|---|---|
| | | | |

### Ce que je retiens / questions d'entretien

- 
