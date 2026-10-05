#!/usr/bin/env bash
# Projet 29 — étape 4 : agent Azure DevOps auto-hébergé, installé comme SERVICE (survit à la déconnexion).
# Usage, sur la VM Ubuntu : AGENT_URL=<URL du .tar.gz affichée par Azure DevOps> AZDO_ORG_URL=https://dev.azure.com/<org> ./setup-agent.sh
# Le script config.sh demandera le PAT (droits "Agent Pools: Read & manage").
set -euo pipefail
: "${AGENT_URL:?AGENT_URL manquant}" "${AZDO_ORG_URL:?AZDO_ORG_URL manquant}"
sudo apt-get update
sudo apt-get install -y docker.io git
sudo usermod -aG docker "$USER"     # l'agent (lancé sous cet utilisateur) doit pouvoir utiliser Docker
mkdir -p ~/myagent && cd ~/myagent
wget -q "$AGENT_URL" -O agent.tar.gz
tar zxf agent.tar.gz && rm agent.tar.gz
./config.sh --url "$AZDO_ORG_URL" --auth pat --pool votingApp-Agent --agent "$(hostname)" --acceptTeeEula
sudo ./svc.sh install "$USER"
sudo ./svc.sh start
sudo ./svc.sh status
