#!/usr/bin/env bash
set -euo pipefail

echo "[1/4] Updating package index..."
sudo apt-get update

echo "[2/4] Installing Prometheus and Node Exporter..."
sudo apt-get install -y prometheus prometheus-node-exporter apt-transport-https wget gnupg

echo "[3/4] Adding the official Grafana APT repository..."
sudo install -d -m 0755 /etc/apt/keyrings
wget -qO- https://apt.grafana.com/gpg-full.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg >/dev/null
sudo chmod 644 /etc/apt/keyrings/grafana.gpg
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee /etc/apt/sources.list.d/grafana.list >/dev/null

sudo apt-get update
sudo apt-get install -y grafana

echo "[4/4] Enabling and starting services..."
sudo systemctl enable --now prometheus-node-exporter
sudo systemctl enable --now prometheus
sudo systemctl enable --now grafana-server

echo
echo "Service status:"
sudo systemctl --no-pager --full status prometheus-node-exporter prometheus grafana-server || true

echo
echo "Installation completed. Configure Prometheus using prometheus/prometheus.yml in this repository."
echo "Do not expose Prometheus (9090) or Node Exporter (9100) publicly."
