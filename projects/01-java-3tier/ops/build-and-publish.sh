#!/usr/bin/env bash
# Projet 01 — sur le serveur Maven : build, analyse SonarCloud, publication du .war dans JFrog.
set -euo pipefail
cd "$(dirname "$0")/../app"
: "${JFROG_USER:?export JFROG_USER=...}"
[ -n "${JFROG_TOKEN:-}" ] || { read -rsp "Token JFrog : " JFROG_TOKEN; echo; export JFROG_TOKEN; }
[ -n "${SONAR_TOKEN:-}" ] || { read -rsp "Token SonarCloud : " SONAR_TOKEN; echo; }
mvn -B -s settings.xml clean verify sonar:sonar -Dsonar.token="$SONAR_TOKEN"
mvn -B -s settings.xml deploy -DskipTests
