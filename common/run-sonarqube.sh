#!/usr/bin/env bash
# Lance SonarQube Community Build en conteneur (base embarquée, pour un lab). Bible : annexe A.4
set -euo pipefail
echo "vm.max_map_count=524288" | sudo tee /etc/sysctl.d/99-sonarqube.conf
echo "fs.file-max=131072"      | sudo tee -a /etc/sysctl.d/99-sonarqube.conf
sudo sysctl --system > /dev/null
docker rm -f sonar 2>/dev/null || true
docker run -d --name sonar --restart unless-stopped -p 9000:9000 \
  -v sonar_data:/opt/sonarqube/data -v sonar_ext:/opt/sonarqube/extensions -v sonar_logs:/opt/sonarqube/logs \
  sonarqube:community
echo "SonarQube démarre sur http://<IP>:9000 (admin/admin) — suivre : docker logs -f sonar"
