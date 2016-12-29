#!/bin/bash

# Install Shadowsocks on CentOS 7
echo "Installing Shadowsocks..."

random-string()
{
    cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w ${1:-32} | head -n 1
}

CONFIG_FILE=/etc/shadowsocks.json
SERVICE_FILE=/etc/systemd/system/shadowsocks.service
SS_PASSWORD=$(random-string 32)
SS_PORT=8388
SS_METHOD=aes-256-cfb
SS_IP=`ip route get 1 | awk '{print $NF;exit}'`

# install pip
apt-get update
apt-get install python-pip
apt-get install python-setuptools
pip install --upgrade pip
pip install shadowsocks

# create shadowsocks config
cat <<EOF | sudo tee ${CONFIG_FILE}
{
  "server":"0.0.0.0",
  "server_port":${SS_PORT},
  "local_server":"127.0.0.1",
  "local_port":1080,
  "password":"${SS_PASSWORD}",
  "timeout":600,
  "method":"${SS_METHOD}"
}
EOF

# create service
cat <<EOF | sudo tee ${SERVICE_FILE}
[Unit]
Description=Shadowsocks

[Service]
TimeoutStartSec=0
ExecStart=/usr/local/bin/ssserver -c ${CONFIG_FILE}

[Install]
WantedBy=multi-user.target
EOF

# start service
systemctl enable shadowsocks
#systemctl start shadowsocks

# view service status
sleep 5
systemctl status shadowsocks -l

echo "================================"
echo ""
echo "Congratulations! Shadowsocks has been installed on your system."
echo "You shadowsocks connection info:"
echo "--------------------------------"
echo "server: ${SS_IP}"
echo "server_port: ${SS_PORT}"
echo "password: ${SS_PASSWORD}"
echo "method: ${SS_METHOD}"
echo "--------------------------------"

# change timezone info
cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
