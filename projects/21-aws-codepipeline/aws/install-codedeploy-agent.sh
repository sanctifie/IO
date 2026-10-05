#!/usr/bin/env bash
# User data / script de préparation de l'instance de déploiement (Ubuntu 24.04).
# Installe Docker + l'agent CodeDeploy depuis le bucket officiel de la région.
set -euo pipefail
REGION="${REGION:-eu-west-3}"

apt-get update
apt-get install -y docker.io ruby-full wget curl
systemctl enable --now docker

cd /tmp
wget -q "https://aws-codedeploy-${REGION}.s3.${REGION}.amazonaws.com/latest/install"
chmod +x install
./install auto
systemctl enable --now codedeploy-agent
systemctl status codedeploy-agent --no-pager
