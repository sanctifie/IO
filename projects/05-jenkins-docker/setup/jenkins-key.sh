#!/usr/bin/env bash
# Projet 05 — à lancer sur le serveur Jenkins : génère la clé de déploiement et l'affiche.
set -euo pipefail
ssh-keygen -t ed25519 -f ~/dockerhost_deploy -N "" -C "jenkins-deploy"
echo "=== Clé PUBLIQUE (à passer à dockerhost.sh) ==="; cat ~/dockerhost_deploy.pub
echo "=== Clé PRIVÉE (à coller dans Jenkins > Credentials > SSH Username with private key, ID dockerhost-ssh) ==="; cat ~/dockerhost_deploy
echo "Une fois copiée dans Jenkins : rm ~/dockerhost_deploy*"
