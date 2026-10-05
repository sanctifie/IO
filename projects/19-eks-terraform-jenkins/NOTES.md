# Projet 19 — EKS + Jenkins + Terraform

> Partie 3 — Conteneurs, Kubernetes, IaC, GitOps · Bible : chapitre « Projet 19 » de `docs/Bible-DevOps-Cloud.pdf`

## Objectif

Deux couches Terraform (serveur Jenkins, cluster EKS) ; Jenkins applique le Terraform du cluster et déploie Nginx.

## Ce que contient ce dossier

```text
Jenkinsfile
jenkins_server/scripts/install_build_tools.sh
jenkins_server/tf-aws-ec2/backend.tf
jenkins_server/tf-aws-ec2/data.tf
jenkins_server/tf-aws-ec2/main.tf
jenkins_server/tf-aws-ec2/outputs.tf
jenkins_server/tf-aws-ec2/provider.tf
jenkins_server/tf-aws-ec2/variables.tf
jenkins_server/tf-aws-ec2/variables/dev.tfvars
manifest/deployment.yaml
manifest/service.yaml
tf-aws-eks/backend.tf
tf-aws-eks/data.tf
tf-aws-eks/eks.tf
tf-aws-eks/provider.tf
tf-aws-eks/variables.tf
tf-aws-eks/vpc.tf
tf-aws-eks/variables/dev.tfvars
```

_Le code source de l'application (dossiers `src/`, `public/`, etc.) n'est pas listé._

## Corrections apportées au code d'origine

- AMI Amazon Linux 2023 cherchée dynamiquement (l'ID d'origine n'existait qu'en us-east-1)
- Rôle IAM d'instance (plus de clés AWS dans Jenkins), IMDSv2, disque 30 Go, SSH/Sonar limités à ton IP
- Modules épinglés ; EKS : version supportée, AL2023, t3.medium, enable_cluster_creator_admin_permissions, add-ons gérés
- Jenkinsfile : paramètre apply/destroy, plan -out puis apply du plan, plan -destroy, stage pré-destroy (load balancer), namespace idempotent
- User data réécrit : pas de newgrp ni chmod 777, Java 21, Terraform épinglé

## Ce qui a été vérifié avant livraison

- terraform validate des deux couches (modules clonés localement)
- shellcheck du user data
- Manifests en dry-run serveur

## À personnaliser avant de lancer

Valeurs d'exemple à remplacer par les tiennes (pseudo, compte, IP, bucket…) :

- `Jenkinsfile` : ligne 19
- `jenkins_server/tf-aws-ec2/backend.tf` : ligne 3
- `jenkins_server/tf-aws-ec2/variables/dev.tfvars` : ligne 9
- `tf-aws-eks/backend.tf` : ligne 3

Et toujours : ta région (`eu-west-3` / `francecentral` par défaut), tes noms uniques (buckets, registres), tes secrets **uniquement** dans les credentials / variables secrètes, jamais dans Git.

## Checklist (étapes de la bible)

- [ ] Étape 1 — Lire et adapter le Terraform du serveur Jenkins
- [ ] Étape 2 — Créer le serveur Jenkins
- [ ] Étape 3 — Le Terraform du cluster EKS
- [ ] Étape 4 — Le pipeline Jenkins
- [ ] Étape 5 — Lancer
- [ ] Captures d'écran des résultats (pipeline vert, application, tableaux de bord)
- [ ] Nettoyage effectué et vérifié dans la console (voir ci-dessous)

## Nettoyage

Pipeline action=destroy, puis terraform destroy dans jenkins_server/tf-aws-ec2 ; vérifier NAT, EIP, load balancers, volumes.

## Mon journal

| Date | Ce que j'ai fait | Problème rencontré | Solution |
|---|---|---|---|
| | | | |

### Ce que je retiens / questions d'entretien

- 
