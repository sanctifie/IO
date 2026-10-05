#!/bin/bash
# Hook ApplicationStop : idempotent (ne doit PAS échouer au tout premier déploiement)
docker rm -f netflix 2>/dev/null || true
docker image prune -af --filter "until=24h" >/dev/null 2>&1 || true
exit 0
