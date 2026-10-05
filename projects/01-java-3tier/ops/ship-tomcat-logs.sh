#!/bin/bash
# Projet 01 — envoie vers S3 les logs Tomcat datés de plus d'un jour, puis les supprime localement (cron quotidien).
set -euo pipefail
BUCKET="${BUCKET:-io-01-logs-PRENOM}"
IID=$(cat /var/lib/cloud/data/instance-id)
cd /opt/tomcat/logs
find . -maxdepth 1 -type f -name '*.20*' -mtime +0 | while read -r f; do
  aws s3 cp "$f" "s3://$BUCKET/$IID/${f#./}" && rm -f "$f"
done
