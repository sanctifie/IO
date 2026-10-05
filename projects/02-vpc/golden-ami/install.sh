#!/usr/bin/env bash
# Projet 02 — à exécuter sur l'instance « ami-builder » (Amazon Linux 2023) avant de créer la Golden AMI.
set -euo pipefail
sudo dnf update -y
sudo dnf install -y httpd git amazon-cloudwatch-agent
sudo systemctl enable httpd
sudo cp "$(dirname "$0")/amazon-cloudwatch-agent.json" /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
sudo systemctl enable amazon-cloudwatch-agent
aws --version && systemctl is-active amazon-ssm-agent
echo "Prêt. Console EC2 → Actions → Image and templates → Create image (io-golden-web-v1)."
