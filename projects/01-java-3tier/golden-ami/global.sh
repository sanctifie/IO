#!/usr/bin/env bash
# Projet 01 — Global AMI (Amazon Linux 2023) : AWS CLI (préinstallée), agent SSM (préinstallé), agent CloudWatch.
set -euo pipefail
sudo dnf update -y
sudo dnf install -y amazon-cloudwatch-agent
sudo cp "$(dirname "$0")/amazon-cloudwatch-agent.json" /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
sudo systemctl enable amazon-cloudwatch-agent
echo "Créer l'AMI io-global-v1"
