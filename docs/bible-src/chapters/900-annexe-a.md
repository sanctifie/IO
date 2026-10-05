@@part Annexes | Recettes, aide-mémoire et glossaire | Les procédures d'installation réutilisées dans plusieurs projets, les commandes à avoir sous la main, le vocabulaire et un planning type pour suivre le parcours.

# Annexe A — Les recettes d'installation

Ces recettes sont écrites pour **Ubuntu 24.04** (serveur). Elles sont référencées dans les projets (« voir annexe A.x »). Quand une version apparaît (`VERSION=…`), va chercher la dernière sur la page indiquée : la procédure ne change pas.

## A.1 — Préparer un serveur Ubuntu

```bash
sudo apt update && sudo apt upgrade -y
sudo hostnamectl set-hostname <nom> && exec bash
sudo timedatectl set-timezone Europe/Paris
sudo apt install -y curl wget unzip git jq ca-certificates gnupg

# Optionnel mais très utile sur une petite instance : 2 Go de swap
sudo fallocate -l 2G /swapfile && sudo chmod 600 /swapfile
sudo mkswap /swapfile && sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

:::warn Pas de swap sur un nœud Kubernetes
Kubernetes (kubeadm) exige par défaut que le swap soit **désactivé**. Ne fais pas cette étape sur les machines de l'annexe A.6.
:::

## A.2 — Docker (dépôt officiel)

```bash
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker

sudo usermod -aG docker $USER          # puis se déconnecter / reconnecter
# Sur un serveur Jenkins :
sudo usermod -aG docker jenkins && sudo systemctl restart jenkins

docker run --rm hello-world
docker compose version
```

*(Version rapide, suffisante pour les exercices : `sudo apt install -y docker.io docker-compose-v2`.)*

## A.3 — Jenkins

```bash
# Java (Jenkins exige Java 17 ou 21)
sudo apt update && sudo apt install -y fontconfig openjdk-21-jre
java -version

# Dépôt officiel Jenkins (version LTS "stable")
sudo wget -O /etc/apt/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
  | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt update && sudo apt install -y jenkins
sudo systemctl enable --now jenkins
sudo systemctl status jenkins --no-pager

# Mot de passe du premier démarrage
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Puis `http://<IP>:8080` → coller le mot de passe → *Install suggested plugins* → créer l'administrateur.

:::tip Si la clé du dépôt a changé
Le nom du fichier de clé (`jenkins.io-2023.key`) est indiqué sur `https://pkg.jenkins.io/debian-stable/`. Si `apt update` affiche `NO_PUBKEY`, récupère le nom actuel sur cette page.
:::

**Réglages de base à faire tout de suite :**
- *Manage Jenkins → Security* : vérifie que l'accès anonyme est désactivé.
- *Manage Jenkins → Nodes → Built-In Node* : 0 exécuteur si tu as des agents.
- *Manage Jenkins → Plugins → Updates* : mets à jour les plugins.
- **Sauvegarde** : tout Jenkins est dans `/var/lib/jenkins` (jobs, credentials chiffrés, plugins).

## A.4 — SonarQube

**Prérequis noyau** (Elasticsearch embarqué) :

```bash
echo "vm.max_map_count=524288" | sudo tee /etc/sysctl.d/99-sonarqube.conf
echo "fs.file-max=131072"      | sudo tee -a /etc/sysctl.d/99-sonarqube.conf
sudo sysctl --system
```

**Version rapide** (base de données embarquée, pour un lab) :

```bash
docker run -d --name sonar --restart unless-stopped -p 9000:9000 \
  -v sonar_data:/opt/sonarqube/data -v sonar_ext:/opt/sonarqube/extensions -v sonar_logs:/opt/sonarqube/logs \
  sonarqube:community
docker logs -f sonar        # attendre "SonarQube is operational"
```

**Version solide** (avec PostgreSQL) : le fichier `compose.yaml` du **projet 16, étape 3**.

Premier accès : `http://<IP>:9000`, `admin` / `admin` → changer le mot de passe → *My Account → Security* → générer un token. Machine : 4 Go de RAM minimum (`t3.medium`).

## A.5 — Trivy

```bash
# Script d'installation officiel (installe le binaire dans /usr/local/bin)
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin
trivy --version

# Premier lancement : télécharge la base de vulnérabilités
trivy image --download-db-only
```

*(Alternative : le dépôt APT officiel, décrit dans la documentation de Trivy, rubrique « Installation ».)* Commandes : voir leçon 14.

## A.6 — Un cluster Kubernetes avec kubeadm (1 master + 1 ou plusieurs workers)

**Machines** : Ubuntu 24.04, `t3.medium` minimum (2 vCPU exigés pour le master), même VPC, Security Group autorisant **tout le trafic entre les nœuds** (et 22 depuis ton IP).

**Sur TOUS les nœuds :**

```bash
# 1. Pas de swap
sudo swapoff -a && sudo sed -i '/ swap / s/^/#/' /etc/fstab

# 2. Modules noyau et réseau
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
sudo modprobe overlay && sudo modprobe br_netfilter
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sudo sysctl --system

# 3. Le moteur de conteneurs : containerd, avec le pilote de cgroups systemd
sudo apt update && sudo apt install -y containerd
sudo mkdir -p /etc/containerd
containerd config default | sudo tee /etc/containerd/config.toml > /dev/null
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd && sudo systemctl enable containerd

# 4. kubeadm, kubelet, kubectl depuis le dépôt officiel pkgs.k8s.io
K8S=v1.34          # ← mets la version mineure stable actuelle (voir https://kubernetes.io/releases/)
sudo apt install -y apt-transport-https ca-certificates curl gpg
curl -fsSL https://pkgs.k8s.io/core:/stable:/$K8S/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/$K8S/deb/ /" \
  | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update && sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl      # empêche les mises à jour accidentelles
sudo systemctl enable --now kubelet
```

:::warn L'ancien dépôt `apt.kubernetes.io` n'existe plus
Beaucoup de tutoriels (dont ceux du dépôt d'origine) utilisent `apt.kubernetes.io` ou `packages.cloud.google.com`, **gelés puis supprimés** en 2024. Seul `pkgs.k8s.io` fonctionne, avec un dépôt **par version mineure**.
:::

**Sur le MASTER uniquement :**

```bash
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
# À la fin, kubeadm affiche une commande "kubeadm join ..." : COPIE-LA.

mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# Le réseau des pods (CNI) : Flannel (simple ; utilise 10.244.0.0/16 par défaut)
kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml
kubectl get pods -A          # attendre que tout soit Running
```

**Sur chaque WORKER :**

```bash
sudo kubeadm join <IP_MASTER>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
# Token perdu ou expiré ? Sur le master : kubeadm token create --print-join-command
```

**Vérification (sur le master) :**

```bash
kubectl get nodes -o wide        # tous les nœuds "Ready" (1 à 2 minutes)
kubectl run test --image=nginx --restart=Never && kubectl get pod test -o wide && kubectl delete pod test
```

:::why Ce que fait `kubeadm init`
Il génère les certificats du cluster, démarre les composants du plan de contrôle (apiserver, etcd, scheduler, controller-manager) **sous forme de pods statiques**, crée la configuration d'administration (`admin.conf`) et un jeton pour que les workers puissent rejoindre le cluster. Sans plugin réseau (CNI), les nœuds restent `NotReady` et CoreDNS en `Pending` : c'est normal tant que Flannel n'est pas installé.
:::

## A.7 — Prometheus, node_exporter, Blackbox Exporter et Grafana (serveur de monitoring)

**Prometheus** (dernière version : `https://github.com/prometheus/prometheus/releases`) :

```bash
sudo useradd --system --no-create-home --shell /bin/false prometheus
VERSION=3.x.y                       # ← à remplacer
cd /tmp && wget https://github.com/prometheus/prometheus/releases/download/v$VERSION/prometheus-$VERSION.linux-amd64.tar.gz
tar xzf prometheus-$VERSION.linux-amd64.tar.gz && cd prometheus-$VERSION.linux-amd64
sudo mv prometheus promtool /usr/local/bin/
sudo mkdir -p /etc/prometheus /data
sudo mv prometheus.yml /etc/prometheus/prometheus.yml
[ -d consoles ] && sudo mv consoles console_libraries /etc/prometheus/    # (absents des versions 3.x)
sudo chown -R prometheus:prometheus /etc/prometheus /data

sudo tee /etc/systemd/system/prometheus.service > /dev/null <<'EOF'
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/data \
  --web.listen-address=0.0.0.0:9090 \
  --web.enable-lifecycle

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload && sudo systemctl enable --now prometheus
sudo journalctl -u prometheus -f --no-pager        # en cas de problème
```

`--web.enable-lifecycle` permet de recharger la configuration sans redémarrer : `curl -X POST http://localhost:9090/-/reload` (après `promtool check config /etc/prometheus/prometheus.yml`).

**node_exporter** (sur chaque machine à surveiller ; `https://github.com/prometheus/node_exporter/releases`) :

```bash
sudo useradd --system --no-create-home --shell /bin/false node_exporter
VERSION=1.x.y
cd /tmp && wget https://github.com/prometheus/node_exporter/releases/download/v$VERSION/node_exporter-$VERSION.linux-amd64.tar.gz
tar xzf node_exporter-$VERSION.linux-amd64.tar.gz
sudo mv node_exporter-$VERSION.linux-amd64/node_exporter /usr/local/bin/

sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<'EOF'
[Unit]
Description=Node Exporter
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Restart=on-failure
ExecStart=/usr/local/bin/node_exporter --collector.logind

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload && sudo systemctl enable --now node_exporter
curl -s localhost:9100/metrics | head
```

**Blackbox Exporter** (`https://github.com/prometheus/blackbox_exporter/releases`) :

```bash
sudo useradd --system --no-create-home --shell /bin/false blackbox
VERSION=0.x.y
cd /tmp && wget https://github.com/prometheus/blackbox_exporter/releases/download/v$VERSION/blackbox_exporter-$VERSION.linux-amd64.tar.gz
tar xzf blackbox_exporter-$VERSION.linux-amd64.tar.gz && cd blackbox_exporter-$VERSION.linux-amd64
sudo mv blackbox_exporter /usr/local/bin/
sudo mkdir -p /etc/blackbox && sudo mv blackbox.yml /etc/blackbox/    # contient le module http_2xx par défaut

sudo tee /etc/systemd/system/blackbox.service > /dev/null <<'EOF'
[Unit]
Description=Blackbox Exporter
After=network-online.target

[Service]
User=blackbox
Restart=on-failure
ExecStart=/usr/local/bin/blackbox_exporter --config.file=/etc/blackbox/blackbox.yml --web.listen-address=:9115

[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload && sudo systemctl enable --now blackbox
curl "http://localhost:9115/probe?target=https://www.google.com&module=http_2xx" | grep probe_success
```

**La configuration Prometheus type :**

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: prometheus
    static_configs: [{ targets: ['localhost:9090'] }]

  - job_name: node_exporter
    static_configs: [{ targets: ['localhost:9100', '<IP_AUTRE_MACHINE>:9100'] }]

  - job_name: jenkins
    metrics_path: /prometheus
    static_configs: [{ targets: ['<IP_JENKINS>:8080'] }]

  - job_name: blackbox
    metrics_path: /probe
    params: { module: [http_2xx] }
    static_configs: [{ targets: ['http://<URL_DE_L_APPLICATION>'] }]
    relabel_configs:
      - { source_labels: [__address__], target_label: __param_target }
      - { source_labels: [__param_target], target_label: instance }
      - { target_label: __address__, replacement: 'localhost:9115' }
```

**Grafana** (dépôt officiel) :

```bash
sudo apt install -y apt-transport-https software-properties-common wget
sudo mkdir -p /etc/apt/keyrings
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" \
  | sudo tee /etc/apt/sources.list.d/grafana.list
sudo apt update && sudo apt install -y grafana
sudo systemctl enable --now grafana-server
```

`http://<IP>:3000` → `admin`/`admin` → nouveau mot de passe → *Connections → Data sources → Add → Prometheus* → URL `http://localhost:9090` → *Save & test* → *Dashboards → New → Import* → ID (1860 Node Exporter Full, 9964 Jenkins, 7587 Blackbox).

:::warn `apt-key` est obsolète
Le tutoriel d'origine utilise `wget … | sudo apt-key add -` et le dépôt `packages.grafana.com`. `apt-key` est déprécié (et absent des Ubuntu récents) ; la méthode moderne place la clé dans `/etc/apt/keyrings/` et la référence avec `signed-by=`, comme ci-dessus.
:::

## A.8 — Un cluster EKS avec eksctl (la méthode rapide)

```bash
eksctl create cluster \
  --name io-lab --region eu-west-3 \
  --nodegroup-name workers --node-type t3.medium \
  --nodes 2 --nodes-min 1 --nodes-max 3 --managed
kubectl get nodes

# Au besoin : fournisseur OIDC (pour IRSA, projet 15)
eksctl utils associate-iam-oidc-provider --cluster io-lab --region eu-west-3 --approve

# Changer la taille du node group
eksctl scale nodegroup --cluster io-lab --region eu-west-3 --name workers --nodes 3

# SUPPRIMER (après avoir supprimé les Services LoadBalancer et les Ingress !)
kubectl get svc -A | grep LoadBalancer
eksctl delete cluster --name io-lab --region eu-west-3
```

Version « fichier de configuration », à versionner dans Git :

```yaml
# cluster.yaml   →   eksctl create cluster -f cluster.yaml
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
  name: io-lab
  region: eu-west-3
iam:
  withOIDC: true
managedNodeGroups:
  - name: workers
    instanceType: t3.medium
    desiredCapacity: 2
    minSize: 1
    maxSize: 3
    volumeSize: 20
```

## A.9 — Nexus Repository

```bash
docker run -d --name nexus --restart unless-stopped -p 8081:8081 -v nexus-data:/nexus-data sonatype/nexus3
sleep 120
docker exec nexus cat /nexus-data/admin.password; echo
```

`http://<IP>:8081` → *Sign in* (`admin` + mot de passe initial) → assistant (nouveau mot de passe, désactiver l'accès anonyme). Dépôts fournis par défaut : `maven-releases`, `maven-snapshots`, `maven-central` (proxy), `maven-public` (groupe). Machine : 4 Go de RAM minimum.

## A.10 — La pile de monitoring sur Kubernetes (kube-prometheus-stack)

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install monitoring prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
kubectl -n monitoring get pods

# Grafana
kubectl -n monitoring port-forward svc/monitoring-grafana 3000:80
kubectl -n monitoring get secret monitoring-grafana -o jsonpath="{.data.admin-password}" | base64 -d; echo
# Prometheus
kubectl -n monitoring port-forward svc/monitoring-kube-prometheus-prometheus 9090:9090

# Désinstaller
helm uninstall monitoring -n monitoring
kubectl delete namespace monitoring
```

La pile installe : Prometheus (via le *Prometheus Operator*), Alertmanager, Grafana avec des dizaines de tableaux de bord Kubernetes prêts, node-exporter (DaemonSet), kube-state-metrics, et des règles d'alerte par défaut. Pour surveiller tes propres applications, on déclare des objets **ServiceMonitor**.

## A.11 — Argo CD (rappel)

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl -n argocd rollout status deploy/argocd-server
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
kubectl -n argocd port-forward svc/argocd-server 8443:443        # https://localhost:8443 (admin)

# CLI
curl -sSL -o argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd /usr/local/bin/argocd && rm argocd
argocd login localhost:8443 --username admin --insecure
```
