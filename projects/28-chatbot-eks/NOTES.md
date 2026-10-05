# Projet 28 — Chatbot UI sur EKS

> Partie 5 — DevSecOps · Bible : chapitre « Projet 28 » de `docs/Bible-DevOps-Cloud.pdf`

## Objectif

Pipeline Jenkins pour une interface de chatbot Next.js, déployée en conteneur puis sur EKS ; la clé OpenAI reste dans un Secret.

## Ce que contient ce dossier

```text
app/.dockerignore
app/.gitignore
app/CONTRIBUTING.md
app/Dockerfile
app/Makefile
app/README.md
app/docker-compose.yml
app/license
app/next-i18next.config.js
app/next.config.js
app/package.json
app/postcss.config.js
app/prettier.config.js
app/tailwind.config.js
app/tsconfig.json
app/vitest.config.ts
app/EKS-TF/backend.tf
app/EKS-TF/data.tf
app/EKS-TF/eks.tf
app/EKS-TF/provider.tf
app/EKS-TF/variables.tf
app/EKS-TF/variables.tfvars
app/EKS-TF/vpc.tf
app/JenkinsFile/Chatbot-Jenkinsfile
app/JenkinsFile/EKS-Jenkinsfile
app/k8s/chatbot-ui.yaml
```

_Le code source de l'application (dossiers `src/`, `public/`, etc.) n'est pas listé._

## Corrections apportées au code d'origine

- URL Git (sous-dossier) → ton dépôt
- « | true » (pipe) → « || true »
- Nom d'image en minuscules et tagué
- Clé NVD, rôle IAM, kubectl set image
- OPENAI_API_KEY via secretKeyRef ; docker-compose exige la variable
- Node 20, image non-root, deps de prod seulement
- EKS-TF = module du projet 19, avec validation humaine

## Ce qui a été vérifié avant livraison

- vitest : 11 tests réussis
- Build Next.js et conteneur testés (interface servie)
- Manifest en dry-run serveur

## À personnaliser avant de lancer

Valeurs d'exemple à remplacer par les tiennes (pseudo, compte, IP, bucket…) :

- `app/EKS-TF/backend.tf` : ligne 3
- `app/JenkinsFile/Chatbot-Jenkinsfile` : lignes 13, 22
- `app/JenkinsFile/EKS-Jenkinsfile` : ligne 16
- `app/k8s/chatbot-ui.yaml` : ligne 21

Et toujours : ta région (`eu-west-3` / `francecentral` par défaut), tes noms uniques (buckets, registres), tes secrets **uniquement** dans les credentials / variables secrètes, jamais dans Git.

## Checklist (étapes de la bible)

- [ ] Étape 1 — Le dépôt
- [ ] Étape 2 — Le serveur Jenkins
- [ ] Étape 3 — Le pipeline EKS
- [ ] Étape 4 — La clé d'API OpenAI
- [ ] Étape 5 — Le pipeline de l'application
- [ ] Captures d'écran des résultats (pipeline vert, application, tableaux de bord)
- [ ] Nettoyage effectué et vérifié dans la console (voir ci-dessous)

## Nettoyage

kubectl delete svc chatbot-service, pipeline EKS action=destroy, révoquer la clé OpenAI de test.

## Mon journal

| Date | Ce que j'ai fait | Problème rencontré | Solution |
|---|---|---|---|
| | | | |

### Ce que je retiens / questions d'entretien

- 
