# Projet 23 — Swiggy : ECS blue/green

> Partie 5 — DevSecOps · Bible : chapitre « Projet 23 » de `docs/Bible-DevOps-Cloud.pdf`

## Objectif

CodePipeline → CodeBuild (Sonar, Trivy, ECR) → déploiement blue/green ECS Fargate via CodeDeploy.

## Ce que contient ce dossier

```text
appspec.yaml
buildspec.yaml
taskdef.json
app/.dockerignore
app/.gitignore
app/Dockerfile
app/Dockerfile.original
app/nginx.conf
app/package.json
aws/setup-prereqs.sh
```

_Le code source de l'application (dossiers `src/`, `public/`, etc.) n'est pas listé._

## Corrections apportées au code d'origine

- buildspec entièrement réécrit (l'original était commenté et mal indenté)
- Scanner Sonar via npx @sonar/scan (le paquet npm ne fournit pas de commande « sonar-scanner »)
- taskdef.json (<IMAGE1_NAME>) et appspec.yaml (<TASK_DEFINITION>)
- Dockerfile Nginx non-root qui garde le port 3000

## Ce qui a été vérifié avant livraison

- Build CRA et image testés (titre « Swiggy App », lien profond 200)
- JSON/YAML validés, shellcheck

## À personnaliser avant de lancer

Valeurs d'exemple à remplacer par les tiennes (pseudo, compte, IP, bucket…) :

- `aws/setup-prereqs.sh` : ligne 31
- `taskdef.json` : ligne 7

Et toujours : ta région (`eu-west-3` / `francecentral` par défaut), tes noms uniques (buckets, registres), tes secrets **uniquement** dans les credentials / variables secrètes, jamais dans Git.

## Checklist (étapes de la bible)

- [ ] Étape 1 — Le serveur SonarQube
- [ ] Étape 2 — Le code et les paramètres
- [ ] Étape 3 — Le `buildspec.yaml`, réécrit
- [ ] Étape 4 — `taskdef.json` et `appspec.yaml`
- [ ] Étape 5 — ALB, deux target groups, cluster et service
- [ ] Étape 6 — Le pipeline
- [ ] Étape 7 — Observer une bascule blue/green
- [ ] Étape 8 (optionnelle) — Notification
- [ ] Captures d'écran des résultats (pipeline vert, application, tableaux de bord)
- [ ] Nettoyage effectué et vérifié dans la console (voir ci-dessous)

## Nettoyage

Service ECS, cluster, ALB + 2 target groups, pipeline, projet CodeBuild, application CodeDeploy, dépôt ECR, paramètres SSM, instance SonarQube.

## Mon journal

| Date | Ce que j'ai fait | Problème rencontré | Solution |
|---|---|---|---|
| | | | |

### Ce que je retiens / questions d'entretien

- 
