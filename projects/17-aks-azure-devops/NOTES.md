# Projet 17 — AKS avec Azure DevOps

> Partie 3 — Conteneurs, Kubernetes, IaC, GitOps · Bible : chapitre « Projet 17 » de `docs/Bible-DevOps-Cloud.pdf`

## Objectif

Construire une image Node.js, la pousser dans ACR et la déployer sur AKS avec un pipeline Azure DevOps.

## Ce que contient ce dossier

```text
azure-pipelines.yml.example
setup.sh
app/.DS_Store
app/.dockerignore
app/Dockerfile
app/README.md
app/app.js
app/package.json
app/manifests/deployment.yml
app/manifests/service.yml
app/views/home.pug
```

_Le code source de l'application (dossiers `src/`, `public/`, etc.) n'est pas listé._

## Corrections apportées au code d'origine

- Dockerfile node:20-alpine, npm ci --omit=dev, package-lock généré
- express/pug à jour
- AKS --attach-acr

## Ce qui a été vérifié avant livraison

- Application testée en local (Node)
- Manifests en dry-run serveur
- Build Docker non testé ici (npm bloqué dans les builds Docker de l'environnement de test)

## À personnaliser avant de lancer

Valeurs d'exemple à remplacer par les tiennes (pseudo, compte, IP, bucket…) :

- `azure-pipelines.yml.example` : lignes 10, 12

Et toujours : ta région (`eu-west-3` / `francecentral` par défaut), tes noms uniques (buckets, registres), tes secrets **uniquement** dans les credentials / variables secrètes, jamais dans Git.

## Checklist (étapes de la bible)

- [ ] Étape 1 — Cloud Shell et Azure DevOps CLI
- [ ] Étape 2 — L'infrastructure : AKS et ACR
- [ ] Étape 3 — Le code de l'application
- [ ] Étape 4 — Créer le pipeline
- [ ] Étape 5 — Lire le pipeline généré
- [ ] Étape 6 — Vérifier
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
