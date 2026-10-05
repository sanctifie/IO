@@part Partie 3 | Kubernetes & Infrastructure as Code | Kubernetes de A à Z, Terraform, Helm et GitOps avec Argo CD. Puis neuf projets : EKS, Terraform 2-tiers, Super Mario, e-commerce avec Helm, Jenkins + Argo CD, AKS, GitOps Java, EKS en Terraform et Azure DevOps + Terraform.

# Leçon 9 — Kubernetes

## Pourquoi Kubernetes ?

Docker lance des conteneurs sur **une** machine. En production, on a des dizaines de machines et des centaines de conteneurs. Qui décide sur quelle machine lancer chaque conteneur ? Qui le relance s'il plante ? Qui en ajoute quand le trafic augmente ? Qui met à jour sans coupure ? Qui répartit le trafic entre les copies ?

**Kubernetes** (abrégé **K8s**) est l'orchestrateur qui fait tout cela. Créé par Google, open source depuis 2014, c'est aujourd'hui le standard de fait. Tous les clouds le proposent en version managée : **EKS** (AWS), **AKS** (Azure), **GKE** (Google).

:::analogy Le chef d'orchestre et la partition
Tu ne dis pas à Kubernetes « lance un conteneur sur la machine 3 ». Tu lui donnes une **partition** (un fichier YAML) : « je veux 3 copies de mon application, chacune avec 256 Mo de mémoire, accessibles sur le port 80 ». Kubernetes s'occupe de faire jouer l'orchestre, et si un musicien s'arrête, il en fait entrer un autre. Tu décris **l'état désiré** ; Kubernetes ramène en permanence **l'état réel** vers l'état désiré. C'est la **boucle de réconciliation**.
:::

## L'architecture d'un cluster

```ascii
 ┌──────────────────────── PLAN DE CONTRÔLE (control plane) ───────────────────────────────┐
 │  kube-apiserver  ◄── kubectl, Jenkins, Argo CD… (tout passe par l'API, port 6443)       │
 │  etcd            : la base de données clé-valeur de l'état du cluster                   │
 │  kube-scheduler  : choisit sur quel nœud placer chaque nouveau pod                      │
 │  controller-manager : les boucles de réconciliation (« il manque 1 pod → en créer un ») │
 └──────────────────────────────────────┬──────────────────────────────────────────────────┘
          (géré par AWS sur EKS, par Azure sur AKS : tu ne le vois pas)
          ┌─────────────────────────────┼────────────────────────────────────┐
 ┌────────▼────────┐          ┌─────────▼───────┐          ┌──────────▼──────┐
 │ NŒUD (worker) 1 │          │ NŒUD 2          │          │ NŒUD 3          │
 │ kubelet         │          │ kubelet         │          │ kubelet         │  agent qui lance les pods
 │ kube-proxy      │          │ kube-proxy      │          │ kube-proxy      │  règles réseau des Services
 │ containerd      │          │ containerd      │          │ containerd      │  moteur de conteneurs
 │ [pod] [pod]     │          │ [pod]           │          │ [pod] [pod]     │
 └─────────────────┘          └─────────────────┘          └─────────────────┘
```

## Les objets à connaître

**Pod** — la plus petite unité : un ou plusieurs conteneurs qui partagent la même IP et peuvent partager des volumes. En pratique, presque toujours **un conteneur par pod**. Un pod est **éphémère** : s'il meurt, il n'est pas ressuscité, il est **remplacé** par un nouveau (avec une nouvelle IP).

**Deployment** — gère un ensemble de pods identiques (*replicas*) : il en maintient le nombre voulu et orchestre les **mises à jour progressives** (*rolling updates*) et les retours arrière. Il s'appuie sur un **ReplicaSet** qu'il crée pour toi. C'est l'objet que tu utiliseras 90 % du temps.

**Service** — une adresse **stable** (nom DNS + IP virtuelle) devant un groupe de pods choisis par **labels**. Les pods vont et viennent ; le Service reste.

| Type de Service | Accessible depuis | Usage |
|---|---|---|
| `ClusterIP` (défaut) | l'intérieur du cluster uniquement | communication entre microservices (`http://backend:8080`) |
| `NodePort` | l'extérieur, via `<IP d'un nœud>:<30000-32767>` | tests, clusters sans load balancer |
| `LoadBalancer` | Internet, via un load balancer du cloud créé automatiquement | exposer une application (attention : un LB payant par Service) |

**Ingress** — un point d'entrée HTTP unique qui route vers plusieurs Services selon le **nom de domaine** ou le **chemin** (`/api` → service api, `/` → service frontend). Nécessite un **Ingress Controller** (NGINX Ingress, AWS Load Balancer Controller qui crée un ALB…). Un seul load balancer pour toutes les applications : bien plus économique.

**Namespace** — un découpage logique du cluster (`dev`, `prod`, `monitoring`, `argocd`…). Les noms doivent être uniques dans un namespace.

**ConfigMap / Secret** — la configuration (non sensible / sensible) injectée dans les pods comme variables d'environnement ou fichiers. Attention : un Secret est seulement **encodé en base64**, pas chiffré (à protéger avec le chiffrement etcd, des droits RBAC stricts, ou un gestionnaire externe).

**Volumes, PersistentVolumeClaim (PVC), StorageClass** — le stockage persistant. Un pod demande « 10 Go » (PVC) ; la StorageClass crée le disque (un volume EBS sur AWS, grâce au **pilote CSI EBS**).

**StatefulSet** — comme un Deployment, mais pour les applications avec état (bases de données) : noms stables (`mysql-0`, `mysql-1`) et un disque dédié par pod. **DaemonSet** : un pod sur **chaque** nœud (agents de logs, de monitoring). **Job / CronJob** : tâches ponctuelles ou planifiées.

**HorizontalPodAutoscaler (HPA)** — ajuste le nombre de replicas selon le CPU ou d'autres métriques.

**RBAC, ServiceAccount** — qui a le droit de faire quoi dans le cluster ; identité des pods.

## Un manifest complet, commenté

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
  namespace: demo
  labels: { app: web }
spec:
  replicas: 3                              # 3 copies
  selector:
    matchLabels: { app: web }              # ce Deployment gère les pods portant app=web
  strategy:
    type: RollingUpdate
    rollingUpdate: { maxSurge: 1, maxUnavailable: 0 }   # jamais moins de 3 pods prêts pendant une mise à jour
  template:                                # le modèle de pod
    metadata:
      labels: { app: web }
    spec:
      containers:
      - name: web
        image: nginx:1.27
        ports: [{ containerPort: 80 }]
        resources:
          requests: { cpu: 100m, memory: 128Mi }   # réservé pour le placement (100m = 0,1 CPU)
          limits:   { cpu: 500m, memory: 256Mi }   # plafond (au-delà de la mémoire : le pod est tué, "OOMKilled")
        readinessProbe:                    # « suis-je prêt à recevoir du trafic ? »
          httpGet: { path: /, port: 80 }
          initialDelaySeconds: 5
        livenessProbe:                     # « suis-je encore vivant ? » sinon redémarrage
          httpGet: { path: /, port: 80 }
          periodSeconds: 10
        env:
        - name: APP_ENV
          valueFrom: { configMapKeyRef: { name: web-config, key: env } }
---
apiVersion: v1
kind: Service
metadata:
  name: web
  namespace: demo
spec:
  type: ClusterIP
  selector: { app: web }                   # envoie le trafic aux pods app=web
  ports:
  - port: 80                               # port du Service
    targetPort: 80                         # port du conteneur
---
apiVersion: v1
kind: ConfigMap
metadata: { name: web-config, namespace: demo }
data:
  env: production
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: web
  namespace: demo
spec:
  ingressClassName: nginx                  # ou "alb" avec l'AWS Load Balancer Controller
  rules:
  - host: web.exemple.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend: { service: { name: web, port: { number: 80 } } }
```

:::why Les labels et sélecteurs : la colle de Kubernetes
Rien n'est relié par un nom ou une IP. Un Deployment trouve ses pods, un Service trouve ses cibles, **grâce aux labels** (`app: web`). Si le `selector` du Service ne correspond pas exactement aux labels des pods, le Service n'a aucune cible et ton application est injoignable, sans message d'erreur. C'est le bug n°1 des débutants : vérifie avec `kubectl get endpoints web`.
:::

## kubectl, l'outil de tous les jours

```bash
kubectl get nodes                          # les nœuds
kubectl get pods -n demo -o wide           # les pods (et sur quel nœud, avec quelle IP)
kubectl get all -n demo                    # pods, services, deployments, replicasets
kubectl get pods -A                        # dans tous les namespaces
kubectl apply -f fichier.yaml              # créer / mettre à jour (déclaratif, rejouable)
kubectl delete -f fichier.yaml             # supprimer ce que décrit le fichier
kubectl describe pod <pod> -n demo         # DÉTAILS + ÉVÉNEMENTS (le premier réflexe en cas de problème)
kubectl logs <pod> -n demo [-f] [--previous]   # logs (--previous : ceux du conteneur précédent qui a planté)
kubectl exec -it <pod> -n demo -- sh       # shell dans le conteneur
kubectl port-forward svc/web 8080:80 -n demo   # accéder à un Service depuis ton poste : http://localhost:8080
kubectl scale deploy/web --replicas=5 -n demo
kubectl set image deploy/web web=nginx:1.28 -n demo   # mise à jour de l'image
kubectl rollout status deploy/web -n demo
kubectl rollout undo deploy/web -n demo    # revenir à la version précédente
kubectl get events -n demo --sort-by=.lastTimestamp
kubectl config get-contexts / use-context  # changer de cluster
kubectl explain deployment.spec.strategy   # documentation intégrée des champs
```

:::tip Un alias qui fait gagner des heures
```bash
echo "alias k=kubectl" >> ~/.bashrc
echo 'source <(kubectl completion bash)' >> ~/.bashrc
echo 'complete -o default -F __start_kubectl k' >> ~/.bashrc
```
Et installe **k9s** (`https://k9scli.io`) : une interface en mode texte pour naviguer dans le cluster.
:::

## Lire l'état d'un pod

| Statut | Signification | Quoi faire |
|---|---|---|
| `Pending` | pas encore placé sur un nœud | `describe` : pas assez de CPU/mémoire ? PVC non satisfait ? |
| `ContainerCreating` | téléchargement de l'image, montage des volumes | patienter ; sinon `describe` |
| `Running` | au moins un conteneur tourne | vérifier `READY 1/1` |
| `ImagePullBackOff` / `ErrImagePull` | impossible de télécharger l'image | nom/tag faux, registre privé sans `imagePullSecret`, droits |
| `CrashLoopBackOff` | le conteneur démarre puis plante en boucle | `kubectl logs --previous` : c'est l'application qui échoue |
| `OOMKilled` | dépassement de la limite mémoire | augmenter `limits.memory` ou corriger la fuite |
| `READY 0/1` en Running | la readinessProbe échoue | vérifier le chemin/port de la probe |

## Où faire tourner Kubernetes pour apprendre ?

| Option | Coût | Pour quoi |
|---|---|---|
| **kind** ou **minikube** sur ton poste | gratuit | apprendre les objets, tester des manifests (fortement recommandé avant d'aller sur EKS) |
| **kubeadm** sur des EC2 (annexe A.6) | quelques centimes/heure | comprendre l'installation d'un cluster (projets 09, 24, 25) |
| **EKS** (annexe A.8) | ~0,10 $/h + nœuds | le vrai service managé AWS (projets 06, 08, 12, 15, 16, 19, 27, 28, 30) |
| **AKS** | nœuds seulement (plan de contrôle gratuit en tier Free) | projets 07, 17, 29 |

```bash
# kind : un cluster Kubernetes dans des conteneurs Docker, en 1 minute
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64 && chmod +x kind && sudo mv kind /usr/local/bin/
kind create cluster --name labo
kubectl get nodes
kind delete cluster --name labo
```

## Les spécificités d'EKS

- **Plan de contrôle** géré par AWS (0,10 $/h). **Nœuds** : des *managed node groups* (EC2 gérées par AWS), ou **Fargate**, ou **Karpenter** (autoscaling intelligent).
- **Authentification** : ton identité IAM est traduite en identité Kubernetes. Méthode moderne : les **access entries** (`aws eks create-access-entry`) ; méthode historique : la ConfigMap `aws-auth`. La commande `aws eks update-kubeconfig` écrit la configuration de `kubectl`.
- **Réseau** : le plugin **VPC CNI** donne à chaque pod une vraie IP du VPC.
- **Droits IAM pour les pods** : **IRSA** (*IAM Roles for Service Accounts*, via un fournisseur OIDC) ou **EKS Pod Identity** (plus récent et plus simple). Indispensables pour l'AWS Load Balancer Controller et le pilote EBS CSI (projet 15).
- **Add-ons** : VPC CNI, CoreDNS, kube-proxy, EBS CSI driver, installables et mis à jour par AWS.

:::danger Le coût d'un cluster EKS
Plan de contrôle 73 $/mois + 2 nœuds `t3.medium` 60 $/mois + NAT 35 $/mois + chaque `LoadBalancer`/`Ingress` 18 $/mois. **Un cluster d'apprentissage se crée en début de session et se détruit en fin de session.** Garde tes manifests et tes commandes dans Git pour tout recréer en 20 minutes.
:::

# Leçon 10 — Terraform

## L'idée

**Terraform** (HashiCorp) décrit l'infrastructure dans des fichiers `.tf` écrits en **HCL**. On déclare **ce qu'on veut**, Terraform calcule **ce qu'il faut faire** pour y arriver (créer, modifier, supprimer) et le fait en appelant les API du cloud. Il fonctionne avec des centaines de fournisseurs (*providers*) : AWS, Azure, Google, Kubernetes, GitHub, Cloudflare…

*(OpenTofu est un fork open source de Terraform, compatible ; tout ce qui suit s'y applique.)*

## Le cycle de travail

```bash
terraform init        # télécharge les providers et modules, configure le backend
terraform fmt         # formate les fichiers
terraform validate    # vérifie la syntaxe
terraform plan        # calcule et AFFICHE les changements (ne modifie rien)
terraform apply       # applique (demande confirmation)
terraform destroy     # détruit tout ce que gère cette configuration
terraform output      # affiche les sorties
terraform state list  # liste les ressources suivies
```

:::tip Lire un plan
Dans la sortie de `plan` : `+` création, `-` destruction, `~` modification sur place, `-/+` **destruction puis recréation** (attention : un serveur ou une base recréés = données perdues). Lis toujours le résumé final `Plan: 3 to add, 1 to change, 0 to destroy` avant de taper `yes`.
:::

## Les blocs du langage

```hcl
# versions.tf — quels providers, quelles versions
terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }   # ~> 5.0 = toute 5.x
  }
}

# provider : comment se connecter
provider "aws" {
  region = var.region
}

# variable : un paramètre d'entrée
variable "region" {
  type    = string
  default = "eu-west-3"
}
variable "instance_count" {
  type        = number
  description = "Nombre de serveurs web"
  default     = 2
}

# data : LIRE quelque chose qui existe déjà
data "aws_availability_zones" "available" { state = "available" }

# resource : CRÉER quelque chose
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags       = { Name = "demo-vpc" }
}

resource "aws_subnet" "public" {
  count             = 2                                     # 2 subnets
  vpc_id            = aws_vpc.main.id                       # RÉFÉRENCE à une autre ressource
  cidr_block        = cidrsubnet("10.0.0.0/16", 8, count.index)   # 10.0.0.0/24, 10.0.1.0/24
  availability_zone = data.aws_availability_zones.available.names[count.index]
}

# locals : des valeurs calculées, pour éviter les répétitions
locals {
  common_tags = { Project = "io", ManagedBy = "terraform" }
}

# output : une valeur à afficher ou à transmettre
output "vpc_id" { value = aws_vpc.main.id }
```

:::why Le graphe de dépendances
`vpc_id = aws_vpc.main.id` crée une **dépendance** : Terraform sait qu'il doit créer le VPC avant le subnet, et le détruire après. Il construit un graphe de toutes les ressources et crée en parallèle tout ce qui peut l'être. Tu n'écris jamais l'ordre ; seulement les liens. (`depends_on` existe pour les rares dépendances invisibles.)
:::

**Fournir les valeurs des variables** : fichier `terraform.tfvars` (chargé automatiquement), `-var-file=prod.tfvars`, `-var="region=eu-west-1"`, ou variables d'environnement `TF_VAR_region`. Les variables sensibles se déclarent avec `sensitive = true` et ne se commitent jamais.

## L'état (state)

Terraform enregistre dans **`terraform.tfstate`** la correspondance entre ton code et les ressources réelles (« `aws_vpc.main` = `vpc-0abc123` »). Sans état, il ne saurait pas ce qu'il a créé.

- Il contient souvent des **secrets en clair** (mots de passe de bases…) : ne jamais le commiter.
- En équipe ou en CI, il doit être **distant** (*remote backend*) et **verrouillé** pendant un `apply` pour empêcher deux modifications simultanées.

```hcl
# backend.tf — état dans S3, verrouillage natif (Terraform >= 1.10)
terraform {
  backend "s3" {
    bucket       = "io-tfstate-<prenom>"
    key          = "projet-11/terraform.tfstate"
    region       = "eu-west-3"
    encrypt      = true
    use_lockfile = true      # verrou via un fichier .tflock dans S3 (remplace la table DynamoDB)
  }
}
```

```bash
# Créer le bucket d'état une fois pour toutes (versionné : on peut revenir à un état précédent)
aws s3api create-bucket --bucket io-tfstate-<prenom> --region eu-west-3 \
  --create-bucket-configuration LocationConstraint=eu-west-3
aws s3api put-bucket-versioning --bucket io-tfstate-<prenom> --versioning-configuration Status=Enabled
```

:::info DynamoDB pour le verrou
Les projets du dépôt d'origine (11, 19, 26) utilisent une table **DynamoDB** pour le verrou (`dynamodb_table = "..."`). C'était la seule méthode avant Terraform 1.10 ; elle fonctionne toujours mais est dépréciée. Si tu suis le code d'origine, crée la table avec une clé de partition `LockID` (type String).
:::

## Les modules

Un **module** est un dossier de fichiers `.tf` réutilisable, avec ses variables (entrées) et ses outputs (sorties). On l'appelle avec un bloc `module` :

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"     # module public du Terraform Registry
  version = "~> 5.0"

  name            = "io-vpc"
  cidr            = "10.0.0.0/16"
  azs             = ["eu-west-3a", "eu-west-3b"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
}

resource "aws_instance" "web" {
  subnet_id = module.vpc.private_subnets[0]      # on utilise une SORTIE du module
  # ...
}
```

Les modules communautaires `terraform-aws-modules/vpc`, `/eks`, `/rds`… sont très utilisés en entreprise (projet 19). Tes propres modules vivent dans un dossier `modules/` (projet 11).

## Les bonnes pratiques

- Structure : `versions.tf`, `providers.tf`, `variables.tf`, `main.tf` (ou un fichier par thème), `outputs.tf`, `terraform.tfvars` (non commité si sensible).
- **Épingle les versions** des providers et des modules.
- **Toujours `plan` avant `apply`**, et en CI : `fmt -check`, `validate`, `plan` sur la PR, `apply` après fusion.
- Ne modifie **jamais à la main** une ressource gérée par Terraform (sinon *drift* : l'état ne correspond plus à la réalité ; `terraform plan` le détecte).
- Analyse de sécurité : **tflint**, **Checkov**, **tfsec/Trivy config**.
- `terraform import` (ou un bloc `import`) pour reprendre sous contrôle une ressource créée à la main.

# Leçon 11 — Helm

Déployer une application dans Kubernetes demande souvent 5 à 15 fichiers YAML (Deployment, Service, Ingress, ConfigMap, Secret, HPA, ServiceAccount…), avec des valeurs qui changent selon l'environnement (nombre de replicas, nom de domaine, tag d'image). **Helm** est le **gestionnaire de paquets de Kubernetes** : il regroupe ces fichiers en un **chart** paramétrable.

```text
mon-chart/
├── Chart.yaml           # nom, version du chart, version de l'application
├── values.yaml          # les valeurs par défaut
└── templates/           # les manifests, avec des trous {{ ... }}
    ├── deployment.yaml
    ├── service.yaml
    └── _helpers.tpl
```

```yaml
# templates/deployment.yaml (extrait)
spec:
  replicas: {{ .Values.replicaCount }}
  template:
    spec:
      containers:
      - name: app
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
```

```yaml
# values.yaml
replicaCount: 2
image:
  repository: moncompte/monapp
  tag: "1.0.0"
```

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami   # ajouter un dépôt de charts
helm repo update
helm search repo nginx
helm install monapp ./mon-chart -n demo --create-namespace          # installer une "release"
helm upgrade --install monapp ./mon-chart -n demo --set image.tag=1.1.0   # installer OU mettre à jour
helm upgrade monapp ./mon-chart -f values-prod.yaml                 # valeurs d'un autre environnement
helm list -A                                                        # les releases installées
helm history monapp -n demo / helm rollback monapp 1 -n demo        # historique et retour arrière
helm template ./mon-chart                                           # afficher le YAML généré sans rien installer
helm uninstall monapp -n demo
helm create mon-chart                                               # générer un chart d'exemple complet
```

Tu utiliseras Helm surtout pour installer des **outils tiers** prêts à l'emploi (AWS Load Balancer Controller, kube-prometheus-stack, Argo CD, NGINX Ingress) et pour empaqueter tes propres applications (projets 06, 15).

# Leçon 12 — GitOps et Argo CD

## Le principe

Dans un pipeline « classique » (push), c'est le serveur de CI qui exécute `kubectl apply` sur le cluster : il doit détenir les identifiants du cluster, et si quelqu'un modifie le cluster à la main, personne ne le remarque.

Le **GitOps** inverse le sens (pull) :

1. L'**état désiré** du cluster (les manifests ou charts) est stocké dans **un dépôt Git**.
2. Un **agent installé dans le cluster** (Argo CD, ou Flux) surveille ce dépôt en permanence.
3. Dès que Git change, l'agent applique le changement. Si le cluster dérive (modification manuelle), l'agent le signale et peut le **corriger automatiquement** (*self-heal*).

```ascii
  CI (Jenkins / GitHub Actions)                         CD (GitOps)
 ┌───────────────────────────────┐                ┌───────────────────────────────┐
 │ build → tests → image:42      │                │ Argo CD (dans le cluster)     │
 │ push image:42 dans le registre│                │  surveille le dépôt manifests │
 │ commit "image: monapp:42"     │──► Dépôt Git ◄─┤  compare Git ↔ cluster        │
 │   dans le dépôt de manifests  │   manifests    │  synchronise → kubectl apply  │
 └───────────────────────────────┘                └───────────────────────────────┘
```

:::why Les bénéfices
- **Git est la source de vérité** : l'historique Git est l'historique des déploiements. Revenir en arrière = `git revert`.
- **Sécurité** : la CI n'a plus besoin d'accès au cluster ; c'est le cluster qui tire les changements.
- **Détection de dérive** : ce qui est dans le cluster correspond toujours à Git.
- **Revue** : un changement de production passe par une pull request.
:::

## Argo CD en pratique

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl -n argocd get pods                     # attendre que tout soit Running
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
kubectl -n argocd port-forward svc/argocd-server 8443:443    # https://localhost:8443 , utilisateur admin
```

Une **Application** Argo CD relie un dépôt Git (et un chemin) à un namespace du cluster :

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: monapp
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/moi/monapp-manifests.git
    targetRevision: main
    path: k8s                         # dossier contenant les manifests (ou un chart Helm)
  destination:
    server: https://kubernetes.default.svc
    namespace: monapp
  syncPolicy:
    automated:
      prune: true                     # supprimer du cluster ce qui a été supprimé de Git
      selfHeal: true                  # annuler les modifications manuelles
    syncOptions: [CreateNamespace=true]
```

Les états affichés : **Synced / OutOfSync** (le cluster correspond-il à Git ?) et **Healthy / Progressing / Degraded** (les ressources fonctionnent-elles ?).

:::interview
- Différence entre un Deployment et un StatefulSet ? entre un Service ClusterIP, NodePort et LoadBalancer ?
- Un pod est en `CrashLoopBackOff` : que fais-tu ? *(`kubectl describe`, `kubectl logs --previous`, vérifier configuration, probes, ressources.)*
- Qu'est-ce que l'état Terraform, pourquoi le stocker à distance et le verrouiller ?
- Qu'apporte Helm par rapport à des fichiers YAML bruts ?
- Explique le GitOps. Push ou pull : quels avantages ?
:::
