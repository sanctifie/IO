#!/bin/bash
# Hook ValidateService : le déploiement n'est "réussi" que si la page répond
for _ in $(seq 1 15); do
  if curl -fsS -o /dev/null http://localhost:8080/; then
    echo "Service OK"
    exit 0
  fi
  sleep 2
done
echo "Le service ne répond pas sur le port 8080" >&2
exit 1
