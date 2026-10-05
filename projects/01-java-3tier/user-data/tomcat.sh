#!/bin/bash
# Projet 01 — user data du Launch Template Tomcat. Adapter les 3 variables ci-dessous.
set -euxo pipefail
exec > /var/log/user-data.log 2>&1
REGION=eu-west-3
JFROG_URL=https://TON-NOM.jfrog.io/artifactory/libs-release-local
JFROG_USER=ton-user-jfrog
APP_VERSION=1.0

p() { aws ssm get-parameter --region "$REGION" --name "$1" --with-decryption --query Parameter.Value --output text; }

cat > /etc/default/dptweb <<ENV
SPRING_DATASOURCE_URL=$(p /io/01/db/url)
SPRING_DATASOURCE_USERNAME=$(p /io/01/db/user)
SPRING_DATASOURCE_PASSWORD=$(p /io/01/db/password)
ENV
chmod 600 /etc/default/dptweb

curl -fsSL -u "$JFROG_USER:$(p /io/01/jfrog/token)" -o /opt/tomcat/webapps/ROOT.war \
  "$JFROG_URL/com/devopsrealtime/dptweb/$APP_VERSION/dptweb-$APP_VERSION.war"
chown tomcat:tomcat /opt/tomcat/webapps/ROOT.war

echo "15 0 * * * root /usr/local/bin/ship-tomcat-logs.sh >> /var/log/ship-logs.log 2>&1" > /etc/cron.d/ship-tomcat-logs
systemctl restart tomcat
