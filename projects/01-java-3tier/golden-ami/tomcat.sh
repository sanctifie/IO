#!/usr/bin/env bash
# Projet 01 — Golden AMI Tomcat 9 + Java 11 (à lancer sur une instance issue de io-global-v1)
# TOMCAT_VERSION : dernière 9.0.x sur https://dlcdn.apache.org/tomcat/tomcat-9/  (PAS Tomcat 10+ : javax vs jakarta)
set -euo pipefail
TOMCAT_VERSION="${TOMCAT_VERSION:?ex: TOMCAT_VERSION=9.0.110}"
sudo dnf install -y java-11-amazon-corretto-headless cronie
curl -fLo /tmp/tomcat.tgz "https://dlcdn.apache.org/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz"
sudo mkdir -p /opt/tomcat
sudo tar -xzf /tmp/tomcat.tgz -C /opt/tomcat --strip-components=1
id tomcat >/dev/null 2>&1 || sudo useradd -r -M -d /opt/tomcat -s /sbin/nologin tomcat
sudo rm -rf /opt/tomcat/webapps/*
sudo chown -R tomcat:tomcat /opt/tomcat
sudo cp "$(dirname "$0")/tomcat.service" /etc/systemd/system/tomcat.service
sudo cp "$(dirname "$0")/../ops/ship-tomcat-logs.sh" /usr/local/bin/ship-tomcat-logs.sh
sudo chmod +x /usr/local/bin/ship-tomcat-logs.sh
sudo systemctl daemon-reload
sudo systemctl enable --now tomcat crond
curl -sI http://localhost:8080 | head -1     # 404 attendu : webapps est vide
echo "Créer l'AMI io-golden-tomcat-v1"
