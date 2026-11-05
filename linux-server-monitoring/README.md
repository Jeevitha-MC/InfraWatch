# Linux Server Monitoring with Prometheus and Grafana

A hands-on SRE monitoring project that collects Linux host metrics from an Ubuntu EC2 instance with **Prometheus Node Exporter**, stores and queries them with **Prometheus**, and visualizes them in **Grafana**.

## Architecture

```text
Ubuntu EC2 instance
       |
       v
Prometheus Node Exporter (:9100)
       |
       v
Prometheus (:9090)
       |
       v
Grafana (:3000)
       |
       v
Linux Server Monitoring dashboard
  - CPU utilization
  - Memory utilization
  - Root filesystem utilization
```

## What this project demonstrates

- Installing and managing Linux services with `systemd`
- Collecting host-level metrics using Node Exporter
- Configuring Prometheus scrape jobs
- Querying time-series metrics with PromQL
- Building Grafana monitoring panels
- Basic service and endpoint troubleshooting

## Implemented dashboard panels

### 1. CPU utilization (%)

```promql
100 * (1 - avg by (instance) (
  rate(node_cpu_seconds_total{mode="idle"}[5m])
))
```

### 2. Memory utilization (%)

```promql
100 * (1 - (
  node_memory_MemAvailable_bytes /
  node_memory_MemTotal_bytes
))
```

### 3. Root filesystem utilization (%)

```promql
100 * (
  1 - (
    node_filesystem_avail_bytes{mountpoint="/", fstype!="rootfs"} /
    node_filesystem_size_bytes{mountpoint="/", fstype!="rootfs"}
  )
)
```

## Repository structure

```text
linux-server-monitoring/
├── README.md
├── prometheus/
│   └── prometheus.yml
├── grafana/
│   └── dashboard.json
├── scripts/
│   └── install-monitoring.sh
├── docs/
│   └── setup-guide.md
└── screenshots/
    └── README.md
```

## Quick start

1. Launch an Ubuntu EC2 instance.
2. Connect to the instance using SSH.
3. Run the installation script:

   ```bash
   chmod +x scripts/install-monitoring.sh
   ./scripts/install-monitoring.sh
   ```

4. Review `prometheus/prometheus.yml` and copy it to `/etc/prometheus/prometheus.yml` if you want to use the repository's scrape configuration.
5. Restart Prometheus:

   ```bash
   sudo systemctl restart prometheus
   ```

6. Confirm the services:

   ```bash
   sudo systemctl is-active prometheus-node-exporter
   sudo systemctl is-active prometheus
   sudo systemctl is-active grafana-server
   ```

7. Access Grafana at `http://<EC2-PUBLIC-IP>:3000` after allowing TCP 3000 from **your IP only** in the EC2 security group.
8. Add a Prometheus data source in Grafana with URL `http://localhost:9090`.
9. Import `grafana/dashboard.json` and select the Prometheus data source when prompted.

> Security: Do not expose ports 9090 or 9100 to the public internet. Restrict Grafana port 3000 to your own IP for a temporary learning lab. Use HTTPS and proper authentication for production deployments. Never commit credentials, private keys, public IPs, or AWS account details.

## Useful troubleshooting commands

```bash
sudo systemctl status prometheus-node-exporter --no-pager
sudo systemctl status prometheus --no-pager
sudo systemctl status grafana-server --no-pager

curl -I http://localhost:9100/metrics
curl -s http://localhost:9090/api/v1/targets

sudo journalctl -u prometheus -n 50 --no-pager
sudo journalctl -u grafana-server -n 50 --no-pager

free -h
df -h
top
sudo ss -tulpn
```

## Project status

- [x] Node Exporter installation and service verification
- [x] Prometheus installation and scrape configuration
- [x] Grafana installation and Prometheus data source connection
- [x] CPU utilization panel
- [x] Memory utilization panel
- [x] Root disk utilization panel
- [ ] Network monitoring panel
- [ ] Alert rules and alert notifications
- [ ] Capture fresh dashboard screenshots from a running environment

The EC2 instance used during the initial hands-on exercise was deleted after completing the CPU, memory, and disk panels. The repository contains the reusable configuration, setup instructions, queries, and a portable dashboard template; screenshots should be added after recreating the environment.

## Learning outcomes

This project provided hands-on practice with Linux observability fundamentals: exporters, scraping, time-series metrics, PromQL, dashboards, service management, and basic troubleshooting.
