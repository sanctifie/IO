#!/usr/bin/env bash
# Projet 01 — range la configuration et les secrets dans SSM Parameter Store (depuis ton poste).
# Usage : DB_ENDPOINT=io-db.xxxx.eu-west-3.rds.amazonaws.com ./put-parameters.sh
set -euo pipefail
: "${DB_ENDPOINT:?DB_ENDPOINT manquant}"
read -rsp "Mot de passe de la base : " DB_PASS; echo
read -rsp "Token JFrog : " JFROG_TOKEN; echo
aws ssm put-parameter --overwrite --name /io/01/db/url  --type String --value "jdbc:mysql://${DB_ENDPOINT}:3306/UserDB?sslMode=REQUIRED"
aws ssm put-parameter --overwrite --name /io/01/db/user --type String --value admin
aws ssm put-parameter --overwrite --name /io/01/db/password --type SecureString --value "$DB_PASS"
aws ssm put-parameter --overwrite --name /io/01/jfrog/token --type SecureString --value "$JFROG_TOKEN"
echo "Paramètres créés sous /io/01/"
