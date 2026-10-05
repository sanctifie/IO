#!/usr/bin/env bash
# Projet 01 — Golden AMI Nginx (à lancer sur une instance issue de io-global-v1)
set -euo pipefail
sudo dnf install -y nginx
sudo systemctl enable nginx
echo "Créer l'AMI io-golden-nginx-v1"
