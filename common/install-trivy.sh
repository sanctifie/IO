#!/usr/bin/env bash
# Installe Trivy. Bible : annexe A.5
set -euo pipefail
curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin
trivy --version
