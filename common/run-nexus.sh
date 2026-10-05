#!/usr/bin/env bash
# Lance Nexus Repository en conteneur. Bible : annexe A.9
set -euo pipefail
docker rm -f nexus 2>/dev/null || true
docker run -d --name nexus --restart unless-stopped -p 8081:8081 -v nexus-data:/nexus-data sonatype/nexus3
echo "Attente du mot de passe initial (2 à 3 minutes)..."
until docker exec nexus test -f /nexus-data/admin.password 2>/dev/null; do sleep 10; done
echo "Mot de passe admin initial : $(docker exec nexus cat /nexus-data/admin.password)"
