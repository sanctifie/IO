# Projet 26 — Terraform + GitLab CI

> Partie 4 — Serverless et services managés · Bible : chapitre « Projet 26 » de `docs/Bible-DevOps-Cloud.pdf`

## Objectif

Terraform modulaire (vpc, web) appliqué par un pipeline GitLab CI avec état S3 partagé, plan en artefact et apply manuel.

## Ce que contient ce dossier

```text
.gitignore
.gitlab-ci.oidc.yml
.gitlab-ci.yml
backend.tf
main.tf
provider.tf
tfstate.config
variables.tf
aws/setup-oidc-gitlab.sh
bootstrap/main.tf
vpc/main.tf
vpc/outputs.tf
vpc/variables.tf
web/main.tf
web/outputs.tf
web/variables.tf
```

_Le code source de l'application (dossiers `src/`, `public/`, etc.) n'est pas listé._

## Corrections apportées au code d'origine

- provider.tf contenait un « clear » parasite (erreur de syntaxe)
- Argument de backend inexistant → backend partiel + tfstate.config (use_lockfile)
- Création du bucket déplacée de vpc/variables.tf vers bootstrap/
- IGW + route (subnet réellement public), SSH limité à ton IP
- AMI dynamique, vpc_security_group_ids
- Pipeline : image hashicorp/terraform épinglée, needs, resource_group, environnement + on_stop ; variante OIDC

## Ce qui a été vérifié avant livraison

- terraform validate (aussi dans l'image du pipeline)
- .gitlab-ci.yml validés contre le schéma officiel GitLab
- shellcheck

## À personnaliser avant de lancer

Valeurs d'exemple à remplacer par les tiennes (pseudo, compte, IP, bucket…) :

- `.gitlab-ci.oidc.yml` : ligne 16
- `aws/setup-oidc-gitlab.sh` : ligne 3
- `tfstate.config` : ligne 2
- `variables.tf` : ligne 9

Et toujours : ta région (`eu-west-3` / `francecentral` par défaut), tes noms uniques (buckets, registres), tes secrets **uniquement** dans les credentials / variables secrètes, jamais dans Git.

## Checklist (étapes de la bible)

- [ ] Étape 1 — Le code et ses défauts
- [ ] Étape 2 — Partie 1 : en local
- [ ] Étape 3 — Le projet GitLab
- [ ] Étape 4 — Le `.gitlab-ci.yml`, modernisé
- [ ] Étape 5 — Exécuter
- [ ] Étape 6 (recommandée) — Sans clé d'accès : OIDC GitLab → AWS
- [ ] Captures d'écran des résultats (pipeline vert, application, tableaux de bord)
- [ ] Nettoyage effectué et vérifié dans la console (voir ci-dessous)

## Nettoyage

Job destroy (ou terraform destroy en local). Le bucket du bootstrap est protégé (prevent_destroy).

## Mon journal

| Date | Ce que j'ai fait | Problème rencontré | Solution |
|---|---|---|---|
| | | | |

### Ce que je retiens / questions d'entretien

- 
