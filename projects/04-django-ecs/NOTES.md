# Projet 04 — Django sur ECS Fargate

> Partie 2 — CI/CD · Bible : chapitre « Projet 04 » de `docs/Bible-DevOps-Cloud.pdf`

## Objectif

Conteneuriser une application Django, la pousser dans ECR et l'exécuter sur ECS Fargate.

## Ce que contient ce dossier

```text
app/.dockerignore
app/Dockerfile
app/manage.py
app/requirements.txt
app/hello_world_django_app/__init__.py
app/hello_world_django_app/asgi.py
app/hello_world_django_app/settings.py
app/hello_world_django_app/urls.py
app/hello_world_django_app/views.py
app/hello_world_django_app/wsgi.py
aws/deploy-ecs.sh
aws/destroy.sh
aws/push-ecr.sh
aws/taskdef.json
```

_Le code source de l'application (dossiers `src/`, `public/`, etc.) n'est pas listé._

## Corrections apportées au code d'origine

- SECRET_KEY et ALLOWED_HOSTS lus dans l'environnement
- Django 5.2 LTS + gunicorn, image python:3.12-slim non-root

## Ce qui a été vérifié avant livraison

- Image construite et /hello/ testé en local
- shellcheck des scripts AWS

## À personnaliser avant de lancer

Et toujours : ta région (`eu-west-3` / `francecentral` par défaut), tes noms uniques (buckets, registres), tes secrets **uniquement** dans les credentials / variables secrètes, jamais dans Git.

## Checklist (étapes de la bible)

- [ ] Étape 1 — Récupérer et comprendre l'application
- [ ] Étape 2 — Moderniser le Dockerfile
- [ ] Étape 3 — Construire et tester en local
- [ ] Étape 4 — Créer le dépôt ECR et y pousser l'image
- [ ] Étape 5 — Créer le cluster ECS
- [ ] Étape 6 — Créer la task definition
- [ ] Étape 7 — Créer le service
- [ ] Étape 8 — Mettre à jour l'application (le vrai cycle de vie)
- [ ] Étape 9 (recommandée) — Un load balancer devant le service
- [ ] Captures d'écran des résultats (pipeline vert, application, tableaux de bord)
- [ ] Nettoyage effectué et vérifié dans la console (voir ci-dessous)

## Nettoyage

aws/destroy.sh : service ECS, cluster, task definitions, dépôt ECR, log group.

## Mon journal

| Date | Ce que j'ai fait | Problème rencontré | Solution |
|---|---|---|---|
| | | | |

### Ce que je retiens / questions d'entretien

- 
