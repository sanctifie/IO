#!/usr/bin/env bash
# Prometheus + node_exporter + Blackbox Exporter + Grafana en services systemd. Bible : annexe A.7
# Versions : https://github.com/prometheus/{prometheus,node_exporter,blackbox_exporter}/releases
set -euo pipefail
PROM_VERSION="${PROM_VERSION:?ex: PROM_VERSION=3.5.0}"
NODE_VERSION="${NODE_VERSION:?ex: NODE_VERSION=1.9.1}"
BB_VERSION="${BB_VERSION:?ex: BB_VERSION=0.27.0}"
ARCH=linux-amd64
cd /tmp

fetch() { # $1=projet $2=version
  wget -q "https://github.com/prometheus/$1/releases/download/v$2/$1-$2.$ARCH.tar.gz"
  tar xzf "$1-$2.$ARCH.tar.gz"
}
unit() { # $1=nom $2=user $3=ExecStart
  sudo tee "/etc/systemd/system/$1.service" > /dev/null <<UNIT
[Unit]
Description=$1
Wants=network-online.target
After=network-online.target

[Service]
User=$2
Group=$2
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=$3

[Install]
WantedBy=multi-user.target
UNIT
}

for u in prometheus node_exporter blackbox; do id "$u" >/dev/null 2>&1 || sudo useradd --system --no-create-home --shell /bin/false "$u"; done

fetch prometheus "$PROM_VERSION"
sudo mv "prometheus-$PROM_VERSION.$ARCH/prometheus" "prometheus-$PROM_VERSION.$ARCH/promtool" /usr/local/bin/
sudo mkdir -p /etc/prometheus /data
[ -f /etc/prometheus/prometheus.yml ] || sudo cp "$(dirname "$0")/prometheus.yml" /etc/prometheus/prometheus.yml 2>/dev/null \
  || sudo mv "prometheus-$PROM_VERSION.$ARCH/prometheus.yml" /etc/prometheus/prometheus.yml
sudo chown -R prometheus:prometheus /etc/prometheus /data
unit prometheus prometheus "/usr/local/bin/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/data --web.listen-address=0.0.0.0:9090 --web.enable-lifecycle"

fetch node_exporter "$NODE_VERSION"
sudo mv "node_exporter-$NODE_VERSION.$ARCH/node_exporter" /usr/local/bin/
unit node_exporter node_exporter "/usr/local/bin/node_exporter --collector.logind"

fetch blackbox_exporter "$BB_VERSION"
sudo mv "blackbox_exporter-$BB_VERSION.$ARCH/blackbox_exporter" /usr/local/bin/
sudo mkdir -p /etc/blackbox && sudo mv "blackbox_exporter-$BB_VERSION.$ARCH/blackbox.yml" /etc/blackbox/
unit blackbox blackbox "/usr/local/bin/blackbox_exporter --config.file=/etc/blackbox/blackbox.yml --web.listen-address=:9115"

sudo install -m 0755 -d /etc/apt/keyrings
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list > /dev/null
sudo apt-get update && sudo apt-get install -y grafana

sudo systemctl daemon-reload
sudo systemctl enable --now prometheus node_exporter blackbox grafana-server
echo "Prometheus :9090  node_exporter :9100  blackbox :9115  Grafana :3000 (admin/admin)"
