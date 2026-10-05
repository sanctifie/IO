#!/bin/bash
# Projet 02 — user data des serveurs web (gabarit Terraform : $${...} = variable Terraform)
set -euxo pipefail
exec > /var/log/user-data.log 2>&1

if [ "${install_pkgs}" = "true" ]; then   # sans Golden AMI : on installe au démarrage (plus lent)
  dnf install -y httpd git
  systemctl enable httpd
fi

git clone --depth 1 "${repo_url}" /tmp/io
cp -r /tmp/io/projects/02-vpc/app/* /var/www/html/

aws s3 cp "s3://${bucket}/app.env" /etc/app.env
# shellcheck disable=SC1091
source /etc/app.env

TOKEN=$(curl -sX PUT http://169.254.169.254/latest/api/token -H "X-aws-ec2-metadata-token-ttl-seconds: 300")
IID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
AZ=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)
echo "<p>$APP_MESSAGE — servi par $IID ($AZ)</p>" > /var/www/html/whoami.html

systemctl restart httpd
