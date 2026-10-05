# Projet 02 — VPC scalable sur AWS

> Partie 1 — Fondations · Bible : chapitre « Projet 02 » de `docs/Bible-DevOps-Cloud.pdf`

## Objectif

Construire en Terraform deux VPC reliés par un Transit Gateway, un bastion, une golden AMI, un NLB et un Auto Scaling Group.

## Ce que contient ce dossier

```text
user-data.sh
app/.gitignore
app/README.md
app/error.htm
app/header.html
app/index.html
app/ok.htm
app/WEB-INF/web.xml
app/css/booNavigation.css
app/css/jquery.bxslider.css
app/css/style.css
app/js/beaverslider-effects.js
app/js/beaverslider.js
app/js/booNavigation.js
app/js/jquery.bxslider.min.js
app/js/jquery.min.js
golden-ami/amazon-cloudwatch-agent.json
golden-ami/install.sh
terraform/compute.tf
terraform/network.tf
terraform/outputs.tf
terraform/terraform.tfvars.example
terraform/variables.tf
terraform/versions.tf
```

_Le code source de l'application (dossiers `src/`, `public/`, etc.) n'est pas listé._

## Corrections apportées au code d'origine

- Architecture entière décrite en Terraform (l'original : clics dans la console)
- NAT Gateway dans le subnet public, routes TGW dans les deux sens, flow logs
- Rôle d'instance au moindre privilège, IMDSv2, Security Group du NLB

## Ce qui a été vérifié avant livraison

- terraform validate / fmt
- shellcheck des scripts user data et golden AMI

## À personnaliser avant de lancer

Et toujours : ta région (`eu-west-3` / `francecentral` par défaut), tes noms uniques (buckets, registres), tes secrets **uniquement** dans les credentials / variables secrètes, jamais dans Git.

## Checklist (étapes de la bible)

- [ ] Étape 1 — Créer la Golden AMI
- [ ] Étape 2 — Préparer l'application et sa configuration
- [ ] Étape 3 — Construire les deux VPC
- [ ] Étape 4 — Relier les VPC avec un Transit Gateway
- [ ] Étape 5 — Les Flow Logs
- [ ] Étape 6 — Le bastion
- [ ] Étape 7 — Le Launch Template
- [ ] Étape 8 — Target Group et Auto Scaling Group
- [ ] Étape 9 — Le Network Load Balancer
- [ ] Étape 10 — Route 53 (optionnel, si tu as un domaine)
- [ ] Captures d'écran des résultats (pipeline vert, application, tableaux de bord)
- [ ] Nettoyage effectué et vérifié dans la console (voir ci-dessous)

## Nettoyage

terraform destroy ; vérifier NAT Gateway, Elastic IP, Transit Gateway (facturé à l'heure), AMI et snapshots.

## Mon journal

| Date | Ce que j'ai fait | Problème rencontré | Solution |
|---|---|---|---|
| | | | |

### Ce que je retiens / questions d'entretien

- 
