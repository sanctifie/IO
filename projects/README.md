# Les 30 projets

Chaque dossier contient le code prêt à l'emploi (corrigé et vérifié) et un `NOTES.md` : objectif, corrections, tests réalisés, valeurs à personnaliser, checklist des étapes de la bible, nettoyage et journal.

Scripts communs (Docker, Jenkins, Kubernetes, monitoring, serveurs EC2 de lab) : [`common/`](../common/).

## Partie 1 — Fondations

| # | Projet | Dossier |
|---|---|---|
| 01 | Application Java 3-tiers sur AWS | [`01-java-3tier`](01-java-3tier/NOTES.md) |
| 02 | VPC scalable sur AWS | [`02-vpc`](02-vpc/NOTES.md) |
| 03 | Linux pour le Cloud & DevOps | [`03-linux`](03-linux/NOTES.md) |

## Partie 2 — CI/CD

| # | Projet | Dossier |
|---|---|---|
| 04 | Django sur ECS Fargate | [`04-django-ecs`](04-django-ecs/NOTES.md) |
| 05 | Jenkins + Docker | [`05-jenkins-docker`](05-jenkins-docker/NOTES.md) |
| 06 | CI/CD avancé (Terraform, Ansible, Jenkins, Sonar, JFrog, EKS) | [`06-advanced-cicd`](06-advanced-cicd/NOTES.md) |
| 07 | Parcours Azure DevOps (AKS, ACR, Key Vault) | [`07-azure-devops`](07-azure-devops/NOTES.md) |
| 10 | .NET sur Azure App Service | [`10-dotnet-azure`](10-dotnet-azure/NOTES.md) |
| 14 | GitHub Actions pour Android | [`14-github-actions-android`](14-github-actions-android/NOTES.md) |

## Partie 3 — Conteneurs, Kubernetes, IaC, GitOps

| # | Projet | Dossier |
|---|---|---|
| 08 | EKS : le jeu 2048 | [`08-eks-2048`](08-eks-2048/NOTES.md) |
| 11 | Terraform 2-tiers (ASG + Aurora) | [`11-terraform-2tier`](11-terraform-2tier/NOTES.md) |
| 12 | Super Mario sur EKS (Terraform) | [`12-super-mario`](12-super-mario/NOTES.md) |
| 15 | Robot Shop sur EKS avec Helm | [`15-robotshop-helm`](15-robotshop-helm/NOTES.md) |
| 16 | Jenkins → Kubernetes avec Argo CD | [`16-jenkins-argocd`](16-jenkins-argocd/NOTES.md) |
| 17 | AKS avec Azure DevOps | [`17-aks-azure-devops`](17-aks-azure-devops/NOTES.md) |
| 18 | GitOps Java (Jenkins, Sonar, Argo CD) | [`18-gitops-java`](18-gitops-java/NOTES.md) |
| 19 | EKS + Jenkins + Terraform | [`19-eks-terraform-jenkins`](19-eks-terraform-jenkins/NOTES.md) |
| 20 | Terraform Azure via Azure DevOps | [`20-azure-devops-terraform`](20-azure-devops-terraform/NOTES.md) |

## Partie 4 — Serverless et services managés

| # | Projet | Dossier |
|---|---|---|
| 21 | CodePipeline / CodeBuild / CodeDeploy | [`21-aws-codepipeline`](21-aws-codepipeline/NOTES.md) |
| 22 | API serverless (Lambda, API Gateway, Aurora) | [`22-serverless`](22-serverless/NOTES.md) |
| 26 | Terraform + GitLab CI | [`26-gitlab-terraform`](26-gitlab-terraform/NOTES.md) |

## Partie 5 — DevSecOps

| # | Projet | Dossier |
|---|---|---|
| 09 | Netflix DevSecOps + monitoring | [`09-netflix-devsecops`](09-netflix-devsecops/NOTES.md) |
| 13 | Zomato DevSecOps | [`13-zomato-devsecops`](13-zomato-devsecops/NOTES.md) |
| 23 | Swiggy : ECS blue/green | [`23-swiggy-ecs-bluegreen`](23-swiggy-ecs-bluegreen/NOTES.md) |
| 24 | .NET DevSecOps (Jenkins, K8s) | [`24-dotnet-monitoring`](24-dotnet-monitoring/NOTES.md) |
| 25 | Petshop : Jenkins + Ansible + K8s | [`25-petshop-ansible`](25-petshop-ansible/NOTES.md) |
| 27 | Reddit sur EKS + Argo CD + monitoring | [`27-reddit-eks-argocd`](27-reddit-eks-argocd/NOTES.md) |
| 28 | Chatbot UI sur EKS | [`28-chatbot-eks`](28-chatbot-eks/NOTES.md) |
| 29 | Vote microservices : Azure DevOps + AKS + Argo CD | [`29-voting-app-aks`](29-voting-app-aks/NOTES.md) |
| 30 | Projet final : Blog sur EKS (Nexus, Sonar, Trivy, monitoring) | [`30-blogging-app-eks`](30-blogging-app-eks/NOTES.md) |

## Ce qui n'a pas pu être vérifié dans l'environnement de préparation

- L'exécution réelle sur AWS / Azure / GitLab / GitHub (aucun compte cloud) : le Terraform est validé, les pipelines vérifiés (actionlint, schéma GitLab, yamllint), mais pas lancés.
- Les pipelines Jenkins (`Jenkinsfile`) : relus, non exécutés (pas de serveur Jenkins).
- Le fonctionnement des pods Kubernetes : les manifests sont validés par l'API d'un vrai serveur Kubernetes (`--dry-run=server`), sans exécution des conteneurs.
- Le build Android (projet 14) et les scans Trivy (bases de données inaccessibles).
