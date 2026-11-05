# Setup guide

## 1. Create the Ubuntu EC2 instance

Use an Ubuntu EC2 instance. For a small learning instance, monitor memory and disk usage carefully when running Prometheus and Grafana together.

## 2. Install monitoring packages

From the repository root on the instance:

```bash
chmod +x scripts/install-monitoring.sh
./scripts/install-monitoring.sh
```

## 3. Configure Prometheus

Back up the default config and install the repository config:

```bash
sudo cp /etc/prometheus/prometheus.yml /etc/prometheus/prometheus.yml.bak
sudo cp prometheus/prometheus.yml /etc/prometheus/prometheus.yml
sudo systemctl restart prometheus
```

Check that Prometheus is running and both scrape targets are healthy:

```bash
sudo systemctl is-active prometheus
curl -s http://localhost:9090/api/v1/targets
```

The Prometheus UI, if accessed locally on the instance, is at `http://localhost:9090`.

## 4. Open Grafana safely

In the EC2 security group, add inbound TCP port 3000 with source set to **My IP**. Do not add public inbound rules for ports 9090 or 9100.

Browse to:

```text
http://<EC2-PUBLIC-IP>:3000
```

Sign in using the credentials configured during installation. Set a strong unique password on first login.

## 5. Add the Prometheus data source

In Grafana:

1. Open **Connections → Data sources**.
2. Select **Add data source → Prometheus**.
3. Set the Prometheus server URL to `http://localhost:9090`.
4. Select **Save & test**.

Grafana and Prometheus run on the same EC2 host, so `localhost` is correct from Grafana's point of view.

## 6. Import the dashboard

Open **Dashboards → New → Import**, upload `grafana/dashboard.json`, select the Prometheus data source when prompted, and import.

## 7. Verify metrics

Try these PromQL expressions in Grafana Explore:

```promql
up
```

```promql
100 * (1 - avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])))
```

```promql
100 * (1 - node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)
```

```promql
100 * (1 - node_filesystem_avail_bytes{mountpoint="/", fstype!="rootfs"} / node_filesystem_size_bytes{mountpoint="/", fstype!="rootfs"})
```
