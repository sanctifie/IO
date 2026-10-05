#!/usr/bin/env bash
# Construit serverless-api.zip (dépendances de production uniquement), comme le fait la CI.
set -euo pipefail
cd "$(dirname "$0")/serverless-api"
npm ci --omit=dev
rm -f ../serverless-api.zip
zip -qr ../serverless-api.zip . -x "*.git*" ".env*"
ls -lh ../serverless-api.zip
