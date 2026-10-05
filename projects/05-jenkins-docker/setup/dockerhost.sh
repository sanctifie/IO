#!/usr/bin/env bash
# Projet 05 — prépare l'hôte Docker (Ubuntu 24.04). Usage : sudo ./dockerhost.sh "<clé publique ssh de Jenkins>"
set -euo pipefail
PUBKEY="${1:?Usage : sudo ./dockerhost.sh \"ssh-ed25519 AAAA... jenkins-deploy\"}"
apt-get update && apt-get install -y docker.io
systemctl enable --now docker
id dockeradmin >/dev/null 2>&1 || useradd -m -s /bin/bash dockeradmin
usermod -aG docker dockeradmin
mkdir -p /opt/docker && chown dockeradmin:dockeradmin /opt/docker
install -d -m 700 -o dockeradmin -g dockeradmin /home/dockeradmin/.ssh
echo "$PUBKEY" >> /home/dockeradmin/.ssh/authorized_keys
chown dockeradmin:dockeradmin /home/dockeradmin/.ssh/authorized_keys && chmod 600 /home/dockeradmin/.ssh/authorized_keys
echo "Hôte Docker prêt (utilisateur dockeradmin, dossier /opt/docker)."
