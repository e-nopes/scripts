#!/bin/bash


PROMETHEUS_DATA_DIR="/data_prometheus"
version="${VERSION:-2.37.0}"
arch="${ARCH:-linux-amd64}"
bin_dir="${BIN_DIR:-/usr/local/bin}"


sudo useradd --system --no-create-home --shell /bin/false prometheus
wget https://github.com/prometheus/prometheus/releases/download/v${version}/prometheus-${version}.linux-amd64.tar.gz

tar xvfz prometheus-${version}.linux-amd64.tar.gz
sudo mkdir -p ${PROMETHEUS_DATA_DIR} /etc/prometheus
cd prometheus-${version}.linux-amd64
sudo mv prometheus promtool /usr/local/bin/
sudo mv consoles/ console_libraries/ /etc/prometheus/
sudo mv prometheus.yml /etc/prometheus/prometheus.yml
sudo chown -R prometheus:prometheus /etc/prometheus/ ${PROMETHEUS_DATA_DIR}/
cd ..

rm -rf prometheus-${version}.linux-amd64



cat <<EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

StartLimitIntervalSec=500
StartLimitBurst=5

[Service]
User=prometheus
Group=prometheus
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/${PROMETHEUS_DATA_DIR} \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries \
  --web.listen-address=0.0.0.0:9090 \
  --web.enable-lifecycle

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable prometheus
sudo systemctl start prometheus



echo "SUCCESS! Prometheus Installation succeeded!"



