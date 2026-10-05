# Projet 20 — Terraform Azure via Azure DevOps

> Partie 3 — Conteneurs, Kubernetes, IaC, GitOps · Bible : chapitre « Projet 20 » de `docs/Bible-DevOps-Cloud.pdf`

## Objectif

Pipeline Azure DevOps réutilisable (template) qui déploie un Service Bus avec Terraform, avec approbation et plusieurs environnements.

## Ce que contient ce dossier

```text
.gitignore
setup.sh
deploy/tfdemo-destroy.yml
deploy/tfdemo-env01-terraform.yml
deploy/tfdemo-env02-terraform.yml
terraform/main.tf
terraform/providers.tf
terraform/servicebus.tf
terraform/tfdemo.env01.tfvars
terraform/tfdemo.env02.tfvars
terraform/variables.tf
```

_Le code source de l'application (dossiers `src/`, `public/`, etc.) n'est pas listé._

## Corrections apportées au code d'origine

- azurerm v4 (batched_operations_enabled, partitioning_enabled), files en for_each
- Clé d'état passée à l'init (une par environnement), use_azuread_auth
- Plan publié en artefact puis appliqué tel quel
- Terraform épinglé, pipeline destroy, variante OIDC sans secret
- tfvars env01/env02 fournis (ils manquaient)

## Ce qui a été vérifié avant livraison

- terraform validate / fmt
- yamllint
- shellcheck de setup.sh

## À personnaliser avant de lancer

Valeurs d'exemple à remplacer par les tiennes (pseudo, compte, IP, bucket…) :

- `terraform/providers.tf` : ligne 17

Et toujours : ta région (`eu-west-3` / `francecentral` par défaut), tes noms uniques (buckets, registres), tes secrets **uniquement** dans les credentials / variables secrètes, jamais dans Git.

## Checklist (étapes de la bible)

- [ ] Étape 1 — L'identité de déploiement
- [ ] Étape 2 — Le stockage de l'état et les droits
- [ ] Étape 3 — Le code Terraform
- [ ] Étape 4 — Le variable group des secrets
- [ ] Étape 5 — Les pipelines : un template, plusieurs environnements
- [ ] Étape 6 — Créer l'environnement et l'approbation
- [ ] Étape 7 — Passer à l'échelle : un deuxième environnement
- [ ] Captures d'écran des résultats (pipeline vert, application, tableaux de bord)
- [ ] Nettoyage effectué et vérifié dans la console (voir ci-dessous)

## Nettoyage

Pipeline deploy/tfdemo-destroy.yml (ou az group delete), puis le groupe de l'état, puis az ad app delete.

## Mon journal

| Date | Ce que j'ai fait | Problème rencontré | Solution |
|---|---|---|---|
| | | | |

### Ce que je retiens / questions d'entretien

- 
