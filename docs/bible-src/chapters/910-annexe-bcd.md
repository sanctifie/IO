# Annexe B — Aide-mémoire

## Linux

| Besoin | Commande |
|---|---|
| Où suis-je / lister / aller | `pwd` · `ls -la` · `cd /chemin` |
| Créer / copier / déplacer / supprimer | `mkdir -p` · `cp -r` · `mv` · `rm -r` |
| Lire un fichier | `cat` · `less` · `head -n 20` · `tail -f` |
| Chercher | `grep -ri "texte" dossier/` · `find / -name "x" 2>/dev/null` |
| Remplacer dans un fichier | `sed -i 's/ancien/nouveau/g' fichier` |
| Écrire en root | `echo "x" \| sudo tee -a /etc/fichier` |
| Droits / propriétaire | `chmod 640 f` · `chmod +x f` · `chown user:groupe f` |
| Utilisateurs / groupes | `useradd -m -s /bin/bash u` · `usermod -aG g u` · `id u` |
| Services | `systemctl status/start/stop/restart/enable X` · `journalctl -u X -f` |
| Processus / ressources | `ps aux` · `top` · `free -h` · `df -h` · `du -sh` |
| Réseau | `ip a` · `ss -tlnp` · `curl -I url` · `ping` · `dig nom` |
| SSH / copie | `ssh -i cle.pem user@ip` · `scp -i cle.pem f user@ip:/tmp/` · `ssh -J bastion cible` |
| Paquets | `apt update && apt install x` (Ubuntu) · `dnf install x` (Amazon Linux 2023) |

## Git

| Besoin | Commande |
|---|---|
| État / différences | `git status` · `git diff` · `git diff --staged` |
| Enregistrer | `git add -p` · `git commit -m "feat: …"` |
| Branches | `git switch -c feature/x` · `git switch main` · `git merge feature/x` |
| Synchroniser | `git pull` · `git push -u origin <branche>` |
| Historique | `git log --oneline --graph --all` |
| Annuler | `git restore f` · `git revert <hash>` · `git stash` / `git stash pop` |

## Docker

| Besoin | Commande |
|---|---|
| Construire / lister | `docker build -t nom:tag .` · `docker images` |
| Lancer / lister | `docker run -d --name n -p 8080:80 image` · `docker ps -a` |
| Logs / shell | `docker logs -f n` · `docker exec -it n sh` |
| Arrêter / supprimer | `docker rm -f n` · `docker rmi image` · `docker system prune -a` |
| Registre | `docker login` · `docker tag a b` · `docker push b` |
| Compose | `docker compose up -d` · `docker compose logs -f` · `docker compose down` |

## Kubernetes

| Besoin | Commande |
|---|---|
| Voir | `kubectl get pods,svc,deploy -n ns -o wide` · `kubectl get all -A` |
| Comprendre un problème | `kubectl describe pod p` · `kubectl logs p [--previous]` · `kubectl get events --sort-by=.lastTimestamp` |
| Appliquer / supprimer | `kubectl apply -f f.yaml` · `kubectl delete -f f.yaml` |
| Accéder | `kubectl port-forward svc/s 8080:80` · `kubectl exec -it p -- sh` |
| Mettre à jour | `kubectl set image deploy/d c=img:tag` · `kubectl rollout status/undo deploy/d` |
| Taille | `kubectl scale deploy/d --replicas=3` · `kubectl autoscale deploy/d --cpu-percent=50 --min=2 --max=6` |
| Contexte | `kubectl config get-contexts` · `kubectl config use-context c` |
| EKS / AKS | `aws eks update-kubeconfig --name c --region r` · `az aks get-credentials -g rg -n c` |

## Terraform

| Besoin | Commande |
|---|---|
| Démarrer | `terraform init [-backend-config=f]` |
| Vérifier | `terraform fmt -recursive` · `terraform validate` |
| Prévoir / appliquer | `terraform plan -out=tfplan` · `terraform apply tfplan` |
| Détruire | `terraform destroy` |
| État | `terraform state list` · `terraform state show <res>` · `terraform output` |
| Débloquer | `terraform force-unlock <ID>` (après vérification !) |

## Helm

`helm repo add n url` · `helm repo update` · `helm upgrade --install r chart -n ns --create-namespace -f values.yaml` · `helm list -A` · `helm history r` · `helm rollback r 1` · `helm template chart` · `helm uninstall r -n ns`

## AWS CLI

| Besoin | Commande |
|---|---|
| Qui suis-je ? | `aws sts get-caller-identity` |
| Instances | `aws ec2 describe-instances --query "Reservations[].Instances[].[InstanceId,State.Name,PublicIpAddress]" --output table` |
| S3 | `aws s3 ls` · `aws s3 cp f s3://b/` · `aws s3 rb s3://b --force` |
| ECR | `aws ecr get-login-password \| docker login --username AWS --password-stdin <compte>.dkr.ecr.<r>.amazonaws.com` |
| Paramètres | `aws ssm put-parameter --name /x --type SecureString --value v` · `aws ssm get-parameter --name /x --with-decryption` |
| Session sans SSH | `aws ssm start-session --target i-…` |

## La check-list de fin de session (anti-facture)

:::clean Avant de fermer ton ordinateur
- [ ] Services Kubernetes `LoadBalancer` et Ingress supprimés (`kubectl get svc -A | grep LoadBalancer`)
- [ ] Clusters EKS / AKS supprimés (`eksctl get cluster --region …`, `az aks list -o table`)
- [ ] `terraform destroy` exécuté dans chaque dossier utilisé
- [ ] Instances EC2 terminées ou arrêtées, **dans toutes les régions utilisées** (EC2 Global View)
- [ ] NAT Gateways, Transit Gateways, Elastic IPs non attachées supprimées
- [ ] Load balancers, target groups, volumes EBS « available », snapshots inutiles supprimés
- [ ] Bases RDS / Aurora supprimées
- [ ] Groupes de ressources Azure supprimés
- [ ] Coup d'œil à *Billing → Bills* / *Cost Explorer* (et le lendemain matin)
:::

# Annexe C — Glossaire

| Terme | Définition |
|---|---|
| **ACR / ECR** | registres d'images de conteneurs d'Azure / d'AWS |
| **Agent (CI)** | machine qui exécute les jobs d'un pipeline (agent Jenkins, runner GitHub/GitLab, agent Azure DevOps) |
| **AKS / EKS / GKE** | Kubernetes managé par Azure / AWS / Google |
| **ALB / NLB** | load balancers AWS de couche 7 (HTTP) / couche 4 (TCP) |
| **AMI** | image de disque à partir de laquelle on lance une instance EC2 |
| **Ansible** | outil de configuration de serveurs, sans agent, par SSH et playbooks YAML |
| **Argo CD** | outil de déploiement continu GitOps pour Kubernetes |
| **Artefact** | produit d'un build (jar, war, image, zip), versionné et stocké |
| **ARN** | identifiant unique d'une ressource AWS |
| **ASG** | Auto Scaling Group : groupe d'instances EC2 dont le nombre s'adapte |
| **AZ** | zone de disponibilité : datacenter(s) isolé(s) d'une région |
| **Backend (Terraform)** | lieu de stockage de l'état Terraform (S3, Azure Storage…) |
| **Bastion** | machine exposée qui sert de point d'entrée SSH vers des machines privées |
| **Blue/green** | déploiement de la nouvelle version à côté de l'ancienne, puis bascule du trafic |
| **Canary** | déploiement progressif de la nouvelle version à une petite partie du trafic |
| **CDN** | réseau de serveurs qui met en cache les contenus près des utilisateurs (CloudFront) |
| **CI / CD** | intégration continue / livraison ou déploiement continu |
| **CIDR** | notation d'une plage d'adresses IP (`10.0.0.0/16`) |
| **CNI** | plugin réseau de Kubernetes (VPC CNI, Flannel, Calico) |
| **ConfigMap / Secret** | configuration non sensible / sensible injectée dans les pods |
| **Conteneur** | processus isolé qui embarque une application et ses dépendances |
| **CRD** | type d'objet Kubernetes personnalisé (Application Argo CD, ServiceMonitor…) |
| **CVE / CVSS** | identifiant public d'une vulnérabilité / score de gravité (0 à 10) |
| **DaemonSet** | objet Kubernetes qui place un pod sur chaque nœud |
| **DAST / SAST / SCA** | tests de sécurité dynamiques / statiques du code / des dépendances |
| **Deployment** | objet Kubernetes qui gère des pods identiques et leurs mises à jour |
| **Dockerfile** | recette de construction d'une image Docker |
| **Drift** | écart entre l'état décrit (Terraform, Git) et la réalité |
| **EBS** | disque réseau attaché à une instance EC2 |
| **Elastic IP** | IP publique fixe d'AWS |
| **Exporter** | programme qui expose des métriques au format Prometheus |
| **Fargate** | exécution de conteneurs sans gérer de serveurs (ECS, EKS) |
| **GitOps** | Git comme source de vérité de l'état d'un système, appliqué par un agent |
| **Golden AMI** | AMI préconfigurée pour un rôle précis |
| **Grafana** | outil de tableaux de bord et de visualisation |
| **Health check** | vérification régulière qu'un service répond correctement |
| **Helm / chart** | gestionnaire de paquets Kubernetes / paquet Helm |
| **HPA** | autoscaling horizontal des pods selon des métriques |
| **IaC** | Infrastructure as Code : infrastructure décrite dans des fichiers versionnés |
| **IAM** | gestion des identités et des droits (AWS) |
| **Idempotence** | propriété d'une opération rejouable sans effet supplémentaire |
| **IGW** | Internet Gateway : porte entre un VPC et Internet |
| **Image (Docker)** | modèle en lecture seule à partir duquel on crée des conteneurs |
| **IMDS** | service de métadonnées d'une instance EC2 (`169.254.169.254`) |
| **Ingress** | point d'entrée HTTP d'un cluster Kubernetes, avec règles de routage |
| **IRSA / Pod Identity** | mécanismes donnant un rôle IAM à un pod EKS |
| **Jenkinsfile** | pipeline Jenkins décrit en code (Groovy) |
| **kubeconfig** | fichier de connexion de kubectl à un ou plusieurs clusters |
| **kubelet** | agent Kubernetes présent sur chaque nœud |
| **Lambda** | fonction exécutée à la demande, sans serveur à gérer |
| **Launch Template** | modèle de lancement d'instances EC2 (AMI, type, SG, user data…) |
| **Manifest** | fichier YAML décrivant des objets Kubernetes |
| **Moindre privilège** | n'accorder que les droits strictement nécessaires |
| **MTTD / MTTR** | temps moyen de détection / de rétablissement d'un incident |
| **Multi-stage build** | Dockerfile en plusieurs étapes, l'image finale ne gardant que le nécessaire |
| **Namespace** | découpage logique d'un cluster Kubernetes |
| **NAT Gateway** | permet aux ressources privées de sortir sur Internet |
| **Nexus / Artifactory** | dépôts d'artefacts |
| **Node group** | groupe de nœuds (EC2) d'un cluster EKS |
| **NodePort** | Service Kubernetes accessible sur un port (30000-32767) de chaque nœud |
| **OIDC** | protocole d'identité utilisé pour des connexions sans secret (GitHub/GitLab → AWS, IRSA) |
| **Pipeline** | suite automatisée d'étapes de build, test et déploiement |
| **Pod** | plus petite unité de Kubernetes : un ou plusieurs conteneurs |
| **Probe** | test de vie (*liveness*) ou de disponibilité (*readiness*) d'un conteneur |
| **Prometheus** | système de collecte et de stockage de métriques |
| **PromQL** | langage de requête de Prometheus |
| **PVC / PV / StorageClass** | demande de stockage / volume / classe de stockage dans Kubernetes |
| **Quality Gate** | ensemble de conditions de qualité qu'un code doit respecter (SonarQube) |
| **RBAC** | contrôle d'accès basé sur des rôles (Kubernetes, Azure) |
| **Région** | zone géographique d'un fournisseur cloud (`eu-west-3` = Paris) |
| **Registre** | serveur qui stocke des images de conteneurs |
| **Replica / ReplicaSet** | copie d'un pod / objet qui maintient N copies |
| **Reverse proxy** | serveur intermédiaire qui transmet les requêtes à une application |
| **Rolling update** | mise à jour progressive, instance par instance |
| **Route 53** | DNS d'AWS |
| **Runner** | agent d'exécution de GitHub Actions ou GitLab CI |
| **S3** | stockage d'objets d'AWS |
| **Security Group** | pare-feu stateful attaché à une ressource AWS |
| **Service (K8s)** | adresse stable devant un groupe de pods |
| **Service connection** | connexion d'Azure DevOps vers un service externe (Azure, registre, GitHub) |
| **ServiceAccount** | identité d'un programme dans Kubernetes |
| **Shift left** | déplacer les contrôles (tests, sécurité) plus tôt dans le cycle |
| **SonarQube** | outil d'analyse statique de qualité et de sécurité du code |
| **SSM** | AWS Systems Manager (Session Manager, Parameter Store…) |
| **State (Terraform)** | fichier qui associe le code Terraform aux ressources réelles |
| **StatefulSet** | objet Kubernetes pour les applications avec état |
| **Subnet** | sous-réseau d'un VPC, dans une seule AZ |
| **Target Group** | groupe de cibles vers lesquelles un load balancer envoie le trafic |
| **Terraform** | outil d'Infrastructure as Code multi-cloud |
| **Transit Gateway** | routeur central reliant plusieurs VPC |
| **Trivy** | scanner de vulnérabilités (images, fichiers, IaC, clusters) |
| **User data** | script exécuté au premier démarrage d'une instance |
| **VPC / VNet** | réseau privé virtuel dans AWS / Azure |
| **VPC endpoint** | accès privé à un service AWS depuis un VPC |
| **WAF** | pare-feu applicatif web (filtre les requêtes HTTP) |
| **Webhook** | appel HTTP envoyé automatiquement lors d'un événement (push Git…) |
| **Workload Identity Federation** | authentification d'un pipeline Azure DevOps sans secret |

# Annexe D — Planning type et suivi

## Un planning sur 7 mois (8 à 10 h par semaine)

| Mois | Contenu | Jalons |
|---|---|---|
| **1** | Partie 0 + leçons 1 à 3, projets **03** et **02** | compte AWS sécurisé, budget, premières instances |
| **2** | Projet **01**, leçons 4 à 8, projets **04** et **05** | première appli 3-tiers, premier pipeline Jenkins |
| **3** | Projets **06**, **14**, **07**, **10** | Ansible, GitHub Actions, Azure DevOps |
| **4** | Leçons 9 à 12, projets **08**, **11**, **12**, **17** | Kubernetes, Terraform, Helm |
| **5** | Projets **15**, **16**, **18**, **19**, **20** | GitOps, EKS en Terraform |
| **6** | Leçon 13, projets **21**, **22**, **26**, leçons 14-15, projet **09** | AWS natif, serverless, DevSecOps |
| **7** | Projets **13**, **23**, **24**, **25**, **27**, **28**, **29**, **30** | portfolio, présentation des projets vitrines |

Si tu as moins de temps, le **parcours essentiel** (≈ 3 mois) : 03 → 02 → 01 → 04 → 05 → 14 → 08 → 11 → 19 → 16 → 09 → 30.

## Le tableau de suivi

| # | Projet | Commencé | Terminé | Nettoyé | NOTES.md | Présenté à voix haute |
|---|---|---|---|---|---|---|
| 03 | Linux | ☐ | ☐ | ☐ | ☐ | ☐ |
| 02 | VPC scalable | ☐ | ☐ | ☐ | ☐ | ☐ |
| 01 | Java 3-tiers | ☐ | ☐ | ☐ | ☐ | ☐ |
| 04 | Django ECS/ECR | ☐ | ☐ | ☐ | ☐ | ☐ |
| 05 | Jenkins + Docker | ☐ | ☐ | ☐ | ☐ | ☐ |
| 06 | Pipeline avancé | ☐ | ☐ | ☐ | ☐ | ☐ |
| 07 | Azure DevOps | ☐ | ☐ | ☐ | ☐ | ☐ |
| 10 | .NET sur Azure | ☐ | ☐ | ☐ | ☐ | ☐ |
| 14 | GitHub Actions Android | ☐ | ☐ | ☐ | ☐ | ☐ |
| 08 | EKS 2048 | ☐ | ☐ | ☐ | ☐ | ☐ |
| 11 | Terraform 2-tiers | ☐ | ☐ | ☐ | ☐ | ☐ |
| 12 | Super Mario | ☐ | ☐ | ☐ | ☐ | ☐ |
| 15 | Robot Shop + Helm | ☐ | ☐ | ☐ | ☐ | ☐ |
| 16 | Jenkins + Argo CD | ☐ | ☐ | ☐ | ☐ | ☐ |
| 17 | AKS + Azure DevOps | ☐ | ☐ | ☐ | ☐ | ☐ |
| 18 | GitOps Java | ☐ | ☐ | ☐ | ☐ | ☐ |
| 19 | EKS Terraform + Jenkins | ☐ | ☐ | ☐ | ☐ | ☐ |
| 20 | Azure DevOps + Terraform | ☐ | ☐ | ☐ | ☐ | ☐ |
| 21 | AWS CodePipeline | ☐ | ☐ | ☐ | ☐ | ☐ |
| 22 | Serverless | ☐ | ☐ | ☐ | ☐ | ☐ |
| 26 | GitLab CI + Terraform | ☐ | ☐ | ☐ | ☐ | ☐ |
| 09 | Netflix DevSecOps | ☐ | ☐ | ☐ | ☐ | ☐ |
| 13 | Zomato | ☐ | ☐ | ☐ | ☐ | ☐ |
| 23 | Swiggy blue/green | ☐ | ☐ | ☐ | ☐ | ☐ |
| 24 | .NET DevSecOps | ☐ | ☐ | ☐ | ☐ | ☐ |
| 25 | Petshop + Ansible | ☐ | ☐ | ☐ | ☐ | ☐ |
| 27 | Reddit + Argo CD | ☐ | ☐ | ☐ | ☐ | ☐ |
| 28 | Chatbot EKS | ☐ | ☐ | ☐ | ☐ | ☐ |
| 29 | Voting App | ☐ | ☐ | ☐ | ☐ | ☐ |
| 30 | Blog App (final) | ☐ | ☐ | ☐ | ☐ | ☐ |

## Les ressources officielles à garder en favoris

| Sujet | Où |
|---|---|
| AWS | `docs.aws.amazon.com` · *AWS Skill Builder* (cours gratuits) · *AWS Pricing Calculator* |
| Azure | `learn.microsoft.com` (parcours gratuits, bacs à sable) |
| Kubernetes | `kubernetes.io/docs` · `killercoda.com` (labs gratuits dans le navigateur) |
| Terraform | `developer.hashicorp.com/terraform` · `registry.terraform.io` |
| Docker | `docs.docker.com` |
| Jenkins | `jenkins.io/doc` |
| GitHub Actions / GitLab CI | `docs.github.com/actions` · `docs.gitlab.com/ee/ci` |
| Argo CD | `argo-cd.readthedocs.io` |
| Prometheus / Grafana | `prometheus.io/docs` · `grafana.com/docs` · `grafana.com/grafana/dashboards` |
| Sécurité | `owasp.org` · `aquasecurity.github.io/trivy` · `docs.sonarsource.com` |
| Le programme d'origine | `github.com/ZaheerrAhmed/DevOps-Projects` |

<p class="lead" style="margin-top:2em;text-align:center">Bonne route. Lis les messages d'erreur, détruis tes clusters, et note tout.</p>
