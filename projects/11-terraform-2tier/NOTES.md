# Projet 11 — Terraform 2-tiers (ASG + Aurora)

> Partie 3 — Conteneurs, Kubernetes, IaC, GitOps · Bible : chapitre « Projet 11 » de `docs/Bible-DevOps-Cloud.pdf`

## Objectif

Infrastructure 2-tiers en modules Terraform : VPC, ALB, ASG, Aurora, et en option CloudFront/WAF/Route 53.

## Ce que contient ce dossier

```text
main/backend.tf
main/main.tf
main/provider.tf
main/variables.tf
main/variables.tfvars
modules/alb-tg/gather.tf
modules/alb-tg/main.tf
modules/alb-tg/variables.tf
modules/aws-autoscaling/deploy.sh
modules/aws-autoscaling/gather.tf
modules/aws-autoscaling/main.tf
modules/aws-autoscaling/variable.tf
modules/aws-iam/iam-instance-profile.tf
modules/aws-iam/iam-policy.json
modules/aws-iam/iam-policy.tf
modules/aws-iam/iam-role.json
modules/aws-iam/iam-role.tf
modules/aws-iam/variables.tf
modules/aws-rds/gather.tf
modules/aws-rds/main.tf
modules/aws-rds/variables.tf
modules/aws-vpc/main.tf
modules/aws-vpc/variables.tf
modules/aws-waf-cdn-acm-route53/acm.tf
modules/aws-waf-cdn-acm-route53/cdn.tf
modules/aws-waf-cdn-acm-route53/gather.tf
modules/aws-waf-cdn-acm-route53/route53.tf
modules/aws-waf-cdn-acm-route53/variables.tf
modules/aws-waf-cdn-acm-route53/waf.tf
modules/security-group/gather.tf
modules/security-group/main.tf
modules/security-group/variable.tf
```

_Le code source de l'application (dossiers `src/`, `public/`, etc.) n'est pas listé._

## Corrections apportées au code d'origine

- Mot de passe RDS en variable sensible (plus dans le tfvars)
- Aurora Serverless v2 0,5–2 ACU au lieu de 2 × db.r5.large
- Partie « edge » (CloudFront, WAF, Route 53) optionnelle : ENABLE_EDGE
- AMI Ubuntu 24.04, t3.micro, backend S3 use_lockfile

## Ce qui a été vérifié avant livraison

- terraform validate / fmt

## À personnaliser avant de lancer

Valeurs d'exemple à remplacer par les tiennes (pseudo, compte, IP, bucket…) :

- `main/backend.tf` : ligne 3

Et toujours : ta région (`eu-west-3` / `francecentral` par défaut), tes noms uniques (buckets, registres), tes secrets **uniquement** dans les credentials / variables secrètes, jamais dans Git.

## Checklist (étapes de la bible)

- [ ] Étape 1 — Récupérer et lire le code
- [ ] Étape 2 — Préparer le backend (état distant)
- [ ] Étape 3 — Les variables
- [ ] Étape 4 — Init, plan, apply
- [ ] Étape 5 — Vérifier
- [ ] Étape 6 — Comprendre les briques « edge »
- [ ] Captures d'écran des résultats (pipeline vert, application, tableaux de bord)
- [ ] Nettoyage effectué et vérifié dans la console (voir ci-dessous)

## Nettoyage

terraform destroy -var-file=variables.tfvars ; vérifier NAT Gateway et snapshots Aurora.

## Mon journal

| Date | Ce que j'ai fait | Problème rencontré | Solution |
|---|---|---|---|
| | | | |

### Ce que je retiens / questions d'entretien

- 
