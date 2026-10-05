#!/bin/bash
# User data du serveur Jenkins (Amazon Linux 2023), exécuté UNE fois en root au premier démarrage.
# Journal : /var/log/cloud-init-output.log
# Corrections par rapport à l'original : pas de `newgrp` (bloquait le script), pas de chmod 777
# sur le socket Docker, pas d'`apt` sur Amazon Linux, versions épinglées, Java 21.
set -euxo pipefail

TERRAFORM_VERSION="1.16.5"   # https://releases.hashicorp.com/terraform/
JENKINS_KEY="jenkins.io-2023.key"   # à vérifier sur https://pkg.jenkins.io/redhat-stable/

dnf -y upgrade
dnf -y install wget unzip git fontconfig java-21-amazon-corretto-headless docker

# --- Jenkins (LTS) --- https://www.jenkins.io/doc/book/installing/linux/#red-hat-centos
wget -qO /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import "https://pkg.jenkins.io/redhat-stable/${JENKINS_KEY}"
dnf -y install jenkins

# --- Docker --- ; jenkins et ec2-user dans le groupe docker (pris en compte au redémarrage du service)
systemctl enable --now docker
usermod -aG docker ec2-user
usermod -aG docker jenkins
systemctl daemon-reload
systemctl enable --now jenkins
systemctl restart jenkins   # recharge les groupes de l'utilisateur jenkins

# --- SonarQube (conteneur) --- ; Elasticsearch embarqué exige vm.max_map_count >= 524288
echo "vm.max_map_count=524288" > /etc/sysctl.d/99-sonarqube.conf
sysctl --system
docker run -d --name sonar --restart unless-stopped -p 9000:9000 sonarqube:community

# --- AWS CLI v2 --- (préinstallée sur AL2023 ; on vérifie seulement)
aws --version

# --- Terraform --- (binaire officiel, version épinglée)
cd /tmp
curl -fsSLo terraform.zip "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
unzip -o terraform.zip terraform -d /usr/local/bin
rm -f terraform.zip

# --- kubectl --- (dernière version stable ; doit rester à ±1 version mineure du cluster)
KUBECTL_VERSION="$(curl -fsSL https://dl.k8s.io/release/stable.txt)"
curl -fsSLo /usr/local/bin/kubectl "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
chmod 0755 /usr/local/bin/kubectl

# --- Trivy --- https://trivy.dev/latest/getting-started/installation/
cat > /etc/yum.repos.d/trivy.repo <<'REPO'
[trivy]
name=Trivy repository
baseurl=https://aquasecurity.github.io/trivy-repo/rpm/releases/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://aquasecurity.github.io/trivy-repo/rpm/public.key
REPO
dnf -y install trivy

# --- Helm 3 ---
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | HELM_INSTALL_DIR=/usr/local/bin bash

# Récapitulatif
java -version
terraform -version
kubectl version --client
helm version
trivy --version
echo "USER DATA TERMINÉ"
