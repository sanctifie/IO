# IO — Parcours DevOps

Suivi de notre progression sur le programme [ZaheerrAhmed/DevOps-Projects](https://github.com/ZaheerrAhmed/DevOps-Projects) (30 projets, du débutant à l'avancé).

## Organisation

- Un dossier par projet : `projects/NN-nom-court/`
- Chaque dossier contient un `NOTES.md` (étapes réalisées, commandes, problèmes rencontrés, captures) et le code/IaC produit.
- On coche la case ici quand un projet est terminé et validé.
- ⚠️ Les projets AWS/Azure créent des ressources payantes : **toujours détruire l'infra à la fin** (`terraform destroy`, suppression des clusters EKS/AKS, NAT Gateways, Load Balancers…).

## Ordre recommandé

L'ordre suit la numérotation d'origine, sauf le projet 03 (Linux) qu'on fait en premier car c'est la base de tout le reste.

### Phase 1 — Fondamentaux (Linux, réseau AWS)

- [ ] **03** — Fun with Linux for Cloud & DevOps Engineers · *Linux, users/permissions, EBS*
- [ ] **02** — Deploy Scalable VPC Architecture on AWS · *VPC, Bastion, Golden AMI, CloudWatch*
- [ ] **01** — Deploy Java Application on AWS 3-Tier Architecture · *VPC, Maven, Nginx, Tomcat, RDS, SonarCloud, JFrog*

### Phase 2 — Conteneurs & premiers pipelines CI/CD

- [ ] **04** — Deploy Django Application on AWS using ECS and ECR · *Docker, ECR, ECS*
- [ ] **05** — Deploy code on a Docker Container using Jenkins on AWS · *Jenkins, Docker*
- [ ] **06** — Entire Advanced CI/CD Pipeline with Major DevOps Tools · *Jenkins, Maven, SonarQube, Nexus, Ansible*
- [ ] **07** — DevOps Journey Using Azure DevOps · *Azure DevOps*
- [ ] **10** — CI/CD pipeline for .NET with the DevOps Starter Project · *Azure DevOps, .NET*
- [ ] **14** — End to End CI/CD using GitHub Actions for Android · *GitHub Actions*

### Phase 3 — Kubernetes & Infrastructure as Code

- [ ] **08** — Kubernetes End to End Project on EKS · *EKS, kubectl*
- [ ] **11** — Two-Tier AWS Infrastructure with Terraform · *Terraform*
- [ ] **12** — Super Mario on Kubernetes using Terraform · *Terraform, EKS*
- [ ] **15** — E-Commerce Three Tier app on AWS EKS with Helm · *EKS, Helm*
- [ ] **16** — Deploy to Kubernetes Using Jenkins (End to End) · *Jenkins, K8s*
- [ ] **17** — Deploying an app to AKS using Azure DevOps · *AKS, Azure DevOps*
- [ ] **18** — Jenkins Pipeline for Java: Maven, SonarQube, Argo CD, Helm, K8s · *GitOps*
- [ ] **19** — EKS Clusters + CI/CD with Jenkins and Terraform · *Terraform, EKS, Jenkins*
- [ ] **20** — Azure DevOps pipeline + Terraform Deployment · *Azure, Terraform*

### Phase 4 — Cloud natif AWS & Serverless

- [ ] **21** — AWS DevOps CI/CD Pipeline · *CodeCommit, CodeBuild, CodeDeploy, CodePipeline*
- [ ] **22** — AWS Fully Serverless Architecture with CI/CD · *Lambda, API Gateway, DynamoDB*
- [ ] **26** — Automate Infrastructure on AWS Using Terraform and GitLab CI/CD · *GitLab CI, Terraform*

### Phase 5 — DevSecOps & Observabilité (avancé)

- [ ] **09** — DevSecOps: Netflix Clone CI/CD with Monitoring · *Jenkins, SonarQube, Trivy, OWASP, Prometheus, Grafana*
- [ ] **13** — Zomato Clone: Secure Deployment with DevSecOps CI/CD
- [ ] **23** — Blue-Green Deployment of Swiggy-Clone on AWS ECS with CodePipeline
- [ ] **24** — Real-Time DevSecOps Pipeline for a DotNet Web App
- [ ] **25** — Petshop Java App with CI/CD, Docker, and Kubernetes
- [ ] **27** — Reddit App on EKS using ArgoCD + monitoring
- [ ] **28** — OpenAI Chatbot UI Deployment in EKS with Jenkins and Terraform
- [ ] **29** — 3-tier Microservice Voting App using ArgoCD and Azure DevOps
- [ ] **30** — Blog App Deployment with EKS, Nexus, SonarQube, Trivy + Monitoring

### Bonus

- [ ] **Full Stack Blogging App** — application support utilisée par le projet 30

## Prérequis généraux

- Compte AWS (Free Tier) avec un utilisateur IAM + MFA, et une **alerte de budget** configurée
- Compte Azure (projets 07, 10, 17, 20, 24, 29)
- Compte GitHub / Docker Hub, SonarCloud, JFrog (projet 01)
- Outils locaux : `git`, `aws` CLI, `terraform`, `docker`, `kubectl`, `helm`
