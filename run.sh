# !/bin/bash

#Define PusProx URL
ProxyURL="<<FillMe>>"
#Define User for Daemons
RunUser="pi"

#Get Node-Exporter
sudo wget -O node-exporter.tar.gz https://github.com/prometheus/node_exporter/releases/download/v1.1.2/node_exporter-1.1.2.linux-armv7.tar.gz
sudo tar -xvf node-exporter.tar.gz --strip-components=1
sudo rm node-exporter.tar.gz
sudo mkdir /opt/node-exporter
sudo mv node_exporter /opt/node-exporter

#Generating DaemonFile for NodeExporter
cat <<EOT >> /etc/systemd/system/nodeexporter.service
[Unit]
Description=Prometheus Node Exporter
Documentation=https://prometheus.io/docs/guides/node-exporter/
After=network-online.target

[Service]
User=$RunUser
Restart=on-failure

ExecStart=/opt/node-exporter/node_exporter --collector.disable-defaults --collector.meminfo --collector.loadavg --collector.thermal_zone

[Install]
WantedBy=multi-user.target
EOT

#Making directory for PushProx
sudo mkdir /opt/pushprox

#Generating DaemonFile for PushProx
cat <<EOT >> /etc/systemd/system/pushprox.service
[Unit]
Description=Prometheus Push Proxy
Documentation=PushProx
After=network-online.target

[Service]
User=$RunUser
Restart=on-failure

ExecStart=/opt/pushprox/pushprox-client --proxy-url=$ProxyURL

[Install]
WantedBy=multi-user.target
EOT
#Reload Daemon and (auto)Start everything
sudo systemctl daemon-reload
sudo systemctl enable nodeexporter
sudo systemctl start nodeexporter
sudo systemctl enable pushprox
sudo systemctl start pushprox