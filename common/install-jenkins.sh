#!/usr/bin/env bash
# Installe Java 21 + Jenkins LTS (Ubuntu). Bible : annexe A.3
set -euo pipefail
JENKINS_KEY="${JENKINS_KEY:-jenkins.io-2023.key}"   # nom à vérifier sur https://pkg.jenkins.io/debian-stable/
sudo apt-get update
sudo apt-get install -y fontconfig openjdk-21-jre git
sudo install -m 0755 -d /etc/apt/keyrings
sudo wget -qO /etc/apt/keyrings/jenkins-keyring.asc "https://pkg.jenkins.io/debian-stable/${JENKINS_KEY}"
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" \
  | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
sudo apt-get update
sudo apt-get install -y jenkins
sudo systemctl enable --now jenkins
echo "Mot de passe initial :"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
