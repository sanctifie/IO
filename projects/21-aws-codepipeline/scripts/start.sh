#!/bin/bash
# Hook ApplicationStart : démarre l'image produite par CE build (nom écrit par CodeBuild dans image.txt)
set -euo pipefail
cd "$(dirname "$0")/.."
IMAGE="$(cat image.txt)"
docker pull "$IMAGE"
docker rm -f netflix 2>/dev/null || true
docker run -d --name netflix --restart unless-stopped -p 8080:80 "$IMAGE"
