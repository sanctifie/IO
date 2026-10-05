#!/usr/bin/env bash
# Projet 01 — Golden AMI Maven (serveur de build). MAVEN_VERSION : https://maven.apache.org/download.cgi
set -euo pipefail
MAVEN_VERSION="${MAVEN_VERSION:?ex: MAVEN_VERSION=3.9.11}"
sudo dnf install -y git java-17-amazon-corretto-devel
curl -fLo /tmp/maven.tgz "https://dlcdn.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz"
sudo tar -xzf /tmp/maven.tgz -C /opt
sudo ln -sfn "/opt/apache-maven-${MAVEN_VERSION}" /opt/maven
sudo tee /etc/profile.d/maven.sh > /dev/null <<'PROFILE'
export JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto
export M2_HOME=/opt/maven
export PATH=$M2_HOME/bin:$PATH
PROFILE
# shellcheck disable=SC1091
source /etc/profile.d/maven.sh && mvn -version
echo "Créer l'AMI io-golden-maven-v1"
