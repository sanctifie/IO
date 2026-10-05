# Projet 12 — Super Mario sur EKS (Terraform)

> Partie 3 — Conteneurs, Kubernetes, IaC, GitOps · Bible : chapitre « Projet 12 » de `docs/Bible-DevOps-Cloud.pdf`

## Objectif

Créer un cluster EKS en Terraform depuis une machine bootstrap et y déployer Super Mario.

## Ce que contient ce dossier

```text
deployment.yaml
script.sh
service.yaml
EKS-TF/backend.tf
EKS-TF/main.tf
EKS-TF/provider.tf
```

_Le code source de l'application (dossiers `src/`, `public/`, etc.) n'est pas listé._

## Corrections apportées au code d'origine

- access_config : le créateur du cluster est admin Kubernetes
- Filtre des AZ non supportées par EKS
- Région / type d'instance en variables, backend S3 use_lockfile
- script.sh corrigé

## Ce qui a été vérifié avant livraison

- terraform validate
- Manifests en dry-run serveur

## À personnaliser avant de lancer

Valeurs d'exemple à remplacer par les tiennes (pseudo, compte, IP, bucket…) :

- `EKS-TF/backend.tf` : ligne 3

Et toujours : ta région (`eu-west-3` / `francecentral` par défaut), tes noms uniques (buckets, registres), tes secrets **uniquement** dans les credentials / variables secrètes, jamais dans Git.

## Checklist (étapes de la bible)

- [ ] Étape 1 — La machine bootstrap
- [ ] Étape 2 — Lire le code Terraform
- [ ] Étape 3 — Adapter le code
- [ ] Étape 4 — Créer le cluster
- [ ] Étape 5 — Déployer Mario
- [ ] Captures d'écran des résultats (pipeline vert, application, tableaux de bord)
- [ ] Nettoyage effectué et vérifié dans la console (voir ci-dessous)

## Nettoyage

kubectl delete service mario-service, puis terraform destroy dans EKS-TF/.

## Mon journal

| Date | Ce que j'ai fait | Problème rencontré | Solution |
|---|---|---|---|
| | | | |

### Ce que je retiens / questions d'entretien

- 
