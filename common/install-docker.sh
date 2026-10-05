#!/usr/bin/env bash
# Installe Docker Engine + Compose depuis le dépôt officiel (Ubuntu). Bible : annexe A.2
set -euo pipefail
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker "${SUDO_USER:-$USER}"
if id jenkins >/dev/null 2>&1; then sudo usermod -aG docker jenkins && sudo systemctl restart jenkins; fi
echo "Docker installé. Déconnecte-toi puis reconnecte-toi pour utiliser docker sans sudo."
