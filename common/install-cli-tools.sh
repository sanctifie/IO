#!/usr/bin/env bash
# AWS CLI v2, Terraform, kubectl, eksctl, Helm (Ubuntu/WSL). Bible : partie 0, étape 5
set -euo pipefail
sudo apt-get update && sudo apt-get install -y curl unzip gnupg lsb-release wget
cd /tmp
curl -fsSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscliv2.zip
unzip -qo awscliv2.zip && sudo ./aws/install --update && rm -rf aws awscliv2.zip
wget -qO- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor --yes -o /usr/share/keyrings/hashicorp.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list > /dev/null
sudo apt-get update && sudo apt-get install -y terraform
curl -fsSLO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -m 0755 kubectl /usr/local/bin/kubectl && rm kubectl
curl -fsSL "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_Linux_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin/
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
aws --version; terraform -version | head -1; kubectl version --client; eksctl version; helm version --short
