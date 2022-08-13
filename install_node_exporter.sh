#!/bin/bash
#update /etc/propmetheus/prometheus.yml after install
#  - job_name: node_export
#    static_configs:
#      - targets: ["localhost:9100"]

version="${VERSION:-1.3.1}"
arch="${ARCH:-linux-amd64}"
bin_dir="${BIN_DIR:-/usr/local/bin}"


wget https://github.com/prometheus/node_exporter/releases/download/v${version}/node_exporter-${version}.${arch}.tar.gz

useradd --system --no-create-home --shell /bin/false node_exporter
    
tar xvfz node_exporter-${version}.${arch}.tar.gz
sudo mv node_exporter-${version}.${arch}/node_exporter ${bin_dir}/
rm -rf node_exporter-${version}.${arch}



cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

StartLimitIntervalSec=500
StartLimitBurst=5

[Service]
User=node_exporter
Group=node_exporter
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/node_exporter \
    --collector.logind

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable node_exporter
sudo systemctl start node_exporter



echo "SUCCESS! node_exporter Installation succeeded!"



