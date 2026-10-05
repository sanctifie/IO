#!/bin/bash
# Met à jour l'image d'un microservice dans k8s-specifications/ puis pousse le commit (Argo CD synchronise).
# Usage : updateK8sManifests.sh <service> <imageRepository> <tag>
# Variables d'environnement : AZDO_PAT (secret), ACR_LOGIN_SERVER, et facultatif AZDO_REPO_URL.
set -euo pipefail

SERVICE="$1"        # vote | result | worker
IMAGE_REPO="$2"     # votingapp/vote
TAG="$3"            # numéro de build
: "${AZDO_PAT:?AZDO_PAT manquant (variable secrète du pipeline)}"
: "${ACR_LOGIN_SERVER:?ACR_LOGIN_SERVER manquant}"
# URL du dépôt courant, fournie par Azure Pipelines (sans le jeton)
REPO="${AZDO_REPO_URL:-${BUILD_REPOSITORY_URI:?BUILD_REPOSITORY_URI manquant}}"
REPO_HOST_PATH="${REPO#https://}"
REPO_HOST_PATH="${REPO_HOST_PATH#*@}"   # retire un éventuel "org@" devant dev.azure.com

WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

git clone "https://pipeline:${AZDO_PAT}@${REPO_HOST_PATH}" "$WORKDIR/repo"
cd "$WORKDIR/repo"

MANIFEST="k8s-specifications/${SERVICE}-deployment.yaml"
sed -i -E "s|^(\s*-?\s*image:).*|\1 ${ACR_LOGIN_SERVER}/${IMAGE_REPO}:${TAG}|" "$MANIFEST"
grep -n "image:" "$MANIFEST"

git config user.email "pipeline@exemple.com"
git config user.name  "Azure Pipeline"
git add "$MANIFEST"
if git diff --cached --quiet; then
  echo "Manifest déjà à jour"
  exit 0
fi
git commit -m "ci: ${SERVICE} -> ${TAG} [skip ci]"
git push origin HEAD:main
