# Projet 21 — CodePipeline / CodeBuild / CodeDeploy

> Partie 4 — Serverless et services managés · Bible : chapitre « Projet 21 » de `docs/Bible-DevOps-Cloud.pdf`

## Objectif

Chaîne AWS native : CodeBuild construit et pousse l'image, CodeDeploy la lance sur EC2, CodePipeline orchestre.

## Ce que contient ce dossier

```text
appspec.yml
buildspec.yaml
app/.dockerignore
app/.gitignore
app/Dockerfile
app/README-upstream.md
app/index.html
app/package.json
app/tsconfig.json
app/tsconfig.node.json
app/vite.config.ts
aws/install-codedeploy-agent.sh
aws/setup.sh
scripts/start.sh
scripts/stop.sh
scripts/validate.sh
```

_Le code source de l'application (dossiers `src/`, `public/`, etc.) n'est pas listé._

## Corrections apportées au code d'origine

- buildspec : nodejs 20, login Docker AVANT le build, tag = commit, image.txt transmis à CodeDeploy, artefact minimal
- appspec : ApplicationStop / ApplicationStart / ValidateService
- Scripts idempotents (stop.sh ne casse plus le 1er déploiement)
- Dockerfile Node 20 ; scripts d'installation de l'agent et de préparation IAM/EC2

## Ce qui a été vérifié avant livraison

- Build Vite de l'app (Node 22), site servi par Nginx, validate.sh et double stop.sh testés
- shellcheck, yamllint

## À personnaliser avant de lancer

Et toujours : ta région (`eu-west-3` / `francecentral` par défaut), tes noms uniques (buckets, registres), tes secrets **uniquement** dans les credentials / variables secrètes, jamais dans Git.

## Checklist (étapes de la bible)

- [ ] Étape 1 — Le code
- [ ] Étape 2 — Les secrets dans Parameter Store
- [ ] Étape 3 — Le projet CodeBuild
- [ ] Étape 4 — L'instance de déploiement
- [ ] Étape 5 — L'application CodeDeploy
- [ ] Étape 6 — Le pipeline
- [ ] Captures d'écran des résultats (pipeline vert, application, tableaux de bord)
- [ ] Nettoyage effectué et vérifié dans la console (voir ci-dessous)

## Nettoyage

Pipeline, projet CodeBuild, application CodeDeploy, instance, buckets S3, paramètres SSM, connexion GitHub, rôles IAM.

## Mon journal

| Date | Ce que j'ai fait | Problème rencontré | Solution |
|---|---|---|---|
| | | | |

### Ce que je retiens / questions d'entretien

- 
