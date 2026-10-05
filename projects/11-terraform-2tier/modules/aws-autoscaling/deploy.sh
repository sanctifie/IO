#!/bin/bash
# Projet 11 — user data des serveurs web : Nginx + un modèle de site statique.
set -euxo pipefail
exec > /var/log/user-data.log 2>&1
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get install -y nginx unzip wget mysql-client   # client MySQL seulement : la base est sur RDS
cd /var/www/html
wget -q https://www.tooplate.com/zip-templates/2135_mini_finance.zip
unzip -q 2135_mini_finance.zip
rm -f 2135_mini_finance.zip index.nginx-debian.html
mv 2135_mini_finance/* . && rmdir 2135_mini_finance
systemctl enable nginx
systemctl restart nginx
