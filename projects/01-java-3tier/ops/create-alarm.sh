#!/usr/bin/env bash
# Projet 01 — topic SNS (e-mail) + alarme « connexions à la base > 100 ».
# Usage : EMAIL=toi@exemple.com ./create-alarm.sh
set -euo pipefail
: "${EMAIL:?EMAIL manquant}"
TOPIC=$(aws sns create-topic --name io-alerts --query TopicArn --output text)
aws sns subscribe --topic-arn "$TOPIC" --protocol email --notification-endpoint "$EMAIL" > /dev/null
aws cloudwatch put-metric-alarm --alarm-name io-db-connections-high \
  --namespace AWS/RDS --metric-name DatabaseConnections --dimensions Name=DBInstanceIdentifier,Value=io-db \
  --statistic Maximum --period 60 --evaluation-periods 1 --threshold 100 \
  --comparison-operator GreaterThanThreshold --alarm-actions "$TOPIC"
echo "Confirme l'abonnement reçu par e-mail. Test : aws cloudwatch set-alarm-state --alarm-name io-db-connections-high --state-value ALARM --state-reason test"
