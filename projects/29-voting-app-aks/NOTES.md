# Projet 29 — Vote microservices : Azure DevOps + AKS + Argo CD

> Partie 5 — DevSecOps · Bible : chapitre « Projet 29 » de `docs/Bible-DevOps-Cloud.pdf`

## Objectif

Un pipeline par microservice (filtre de chemins), images dans ACR, mise à jour GitOps des manifests, Argo CD sur AKS.

## Ce que contient ce dossier

```text
setup-agent.sh
setup-azure.sh
app/.gitignore
app/LICENSE
app/README.md
app/docker-compose.images.yml
app/docker-compose.yml
app/argocd/application.yaml
app/k8s-specifications/db-deployment.yaml
app/k8s-specifications/db-service.yaml
app/k8s-specifications/redis-deployment.yaml
app/k8s-specifications/redis-service.yaml
app/k8s-specifications/result-deployment.yaml
app/k8s-specifications/result-service.yaml
app/k8s-specifications/vote-deployment.yaml
app/k8s-specifications/vote-service.yaml
app/k8s-specifications/worker-deployment.yaml
app/result/.dockerignore
app/result/Dockerfile
app/result/azure-pipelines-result.yml
app/result/docker-compose.test.yml
app/result/package.json
app/result/server.js
app/result/tests/Dockerfile
app/result/tests/render.js
app/result/tests/tests.sh
app/result/views/angular.min.js
app/result/views/app.js
app/result/views/index.html
app/result/views/socket.io.js
app/result/views/stylesheets/style.css
app/scripts/updateK8sManifests.sh
app/vote/Dockerfile
app/vote/app.py
app/vote/azure-pipelines-vote.yml
app/vote/requirements.txt
app/worker/Dockerfile
app/worker/Program.cs
app/worker/Worker.csproj
app/worker/azure-pipelines-worker.yml
```

_Le code source de l'application (dossiers `src/`, `public/`, etc.) n'est pas listé._

## Corrections apportées au code d'origine

- PAT en variable secrète (il était écrit dans le script)
- Script GitOps : dossier temporaire, aucun commit vide, [skip ci]
- buildContext explicite, checkout: none au stage Push
- AKS --attach-acr (aucun imagePullSecret)
- Agent auto-hébergé installé en service

## Ce qui a été vérifié avant livraison

- Pile Docker Compose démarrée : un vote traverse Redis → worker → Postgres (vérifié en SQL), page résultats 200
- Substitution d'image vérifiée + dry-run serveur, Application Argo CD validée
- shellcheck, yamllint

## À personnaliser avant de lancer

Valeurs d'exemple à remplacer par les tiennes (pseudo, compte, IP, bucket…) :

- `app/argocd/application.yaml` : ligne 10
- `app/result/azure-pipelines-result.yml` : ligne 15
- `app/vote/azure-pipelines-vote.yml` : ligne 15
- `app/worker/azure-pipelines-worker.yml` : ligne 15

Et toujours : ta région (`eu-west-3` / `francecentral` par défaut), tes noms uniques (buckets, registres), tes secrets **uniquement** dans les credentials / variables secrètes, jamais dans Git.

## Checklist (étapes de la bible)

- [ ] Étape 1 — Tester l'application en local avec Docker Compose
- [ ] Étape 2 — Projet Azure DevOps et import du dépôt
- [ ] Étape 3 — Azure Container Registry
- [ ] Étape 4 — L'agent auto-hébergé
- [ ] Étape 5 — Un pipeline par microservice
- [ ] Étape 6 — Le script de mise à jour des manifests
- [ ] Étape 7 — AKS et Argo CD
- [ ] Étape 8 — Autoriser AKS à tirer les images
- [ ] Étape 9 — Vérifier le CI/CD
- [ ] Captures d'écran des résultats (pipeline vert, application, tableaux de bord)
- [ ] Nettoyage effectué et vérifié dans la console (voir ci-dessous)

## Nettoyage

az group delete -n voting-rg ; supprimer l'agent du pool et la VM ; révoquer les PAT.

## Mon journal

| Date | Ce que j'ai fait | Problème rencontré | Solution |
|---|---|---|---|
| | | | |

### Ce que je retiens / questions d'entretien

- 
