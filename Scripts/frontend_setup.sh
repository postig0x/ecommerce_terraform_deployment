#!/bin/bash
# frontend_setup.sh

# log script output
exec > /home/ubuntu/user_data.log 2>&1

#             _                  _      _
#  __ ___  __| |___ _ _    _____| |_   | |_____ _  _
# / _/ _ \/ _` / _ \ ' \  (_-<_-< ' \  | / / -_) || |
# \__\___/\__,_\___/_||_| /__/__/_||_| |_\_\___|\_, |
#                                               |__/
# give codon access for workload grading
SSH_PUBKEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDSkMc19m28614Rb3sGEXQUN+hk4xGiufU9NYbVXWGVrF1bq6dEnAD/VtwM6kDc8DnmYD7GJQVvXlDzvlWxdpBaJEzKziJ+PPzNVMPgPhd01cBWPv82+/Wu6MNKWZmi74TpgV3kktvfBecMl+jpSUMnwApdA8Tgy8eB0qELElFBu6cRz+f6Bo06GURXP6eAUbxjteaq3Jy8mV25AMnIrNziSyQ7JOUJ/CEvvOYkLFMWCF6eas8bCQ5SpF6wHoYo/iavMP4ChZaXF754OJ5jEIwhuMetBFXfnHmwkrEIInaF3APIBBCQWL5RC4sJA36yljZCGtzOi5Y2jq81GbnBXN3Dsjvo5h9ZblG4uWfEzA2Uyn0OQNDcrecH3liIpowtGAoq8NUQf89gGwuOvRzzILkeXQ8DKHtWBee5Oi/z7j9DGfv7hTjDBQkh28LbSu9RdtPRwcCweHwTLp4X3CYLwqsxrIP8tlGmrVoZZDhMfyy/bGslZp5Bod2wnOMlvGktkHs="
echo "$SSH_PUBKEY" >> /home/ubuntu/.ssh/authorized_keys

echo "${ssh_key}" > /home/ubuntu/.ssh/ecomm_key.pem

#                _      _                    _
#  _  _ _ __  __| |__ _| |_ ___   ____  _ __| |_ ___ _ __
# | || | '_ \/ _` / _` |  _/ -_) (_-< || (_-<  _/ -_) '  \
#  \_,_| .__/\__,_\__,_|\__\___| /__/\_, /__/\__\___|_|_|_|
#      |_|                           |__/
# do not upgrade (keep disk use low)
sudo apt update

# install git, curl, wget
sudo apt install -y git curl wget
# clone github repo, rename to deployment
git clone https://github.com/postig0x/ecommerce_terraform_deployment.git /home/ubuntu/deployment
# setup frontend config
sed -i "s/http:\/\/private_ec2_ip:8000/http:\/\/${BACKEND_PRIVATE_IP}:8000/" /home/ubuntu/deployment/frontend/package.json

#               _                             _
#  _ _  ___  __| |___   _____ ___ __  ___ _ _| |_ ___ _ _
# | ' \/ _ \/ _` / -_) / -_) \ / '_ \/ _ \ '_|  _/ -_) '_|
# |_||_\___/\__,_\___| \___/_\_\ .__/\___/_|  \__\___|_|
#                              |_|
# download and install node exporter
NODE_EXPORTER_VERSION="1.8.2"
wget https://github.com/prometheus/node_exporter/releases/download/v$NODE_EXPORTER_VERSION/node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz
tar xvfz node_exporter-$NODE_EXPORTER_VERSION.linux-amd64.tar.gz
sudo mv node_exporter-$NODE_EXPORTER_VERSION.linux-amd64/node_exporter /usr/local/bin
rm -rf node_exporter-$NODE_EXPORTER_VERSION.linux-amd64*

# create node exporter user
sudo useradd --no-create-home --shell /bin/false node_exporter

# create node exporter service file
cat << EOF | sudo tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# reload systemd, start and enable Node Exporter service
sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter

# print public IP address and Node Exporter port
echo "Node Exporter installation complete. It's accessible at http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):9100/metrics"

#               _        _
#  _ _  ___  __| |___   (_)___
# | ' \/ _ \/ _` / -_)_ | (_-<
# |_||_\___/\__,_\___(_)/ /__/
#                     |__/
# install node
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs
sleep 2

#                  _      _
#  _ _ ___ __ _ __| |_   (_)___
# | '_/ -_) _` / _|  _|_ | (_-<
# |_| \___\__,_\__|\__(_)/ /__/
#                      |__/
# install frontend dependencies
cd /home/ubuntu/deployment/frontend && npm i
# set node legacy compatibility
export NODE_OPTIONS=--openssl-legacy-provider
# by way of Jon W. - add logs
mkdir -p /home/ubuntu/logs && touch /home/ubuntu/logs/frontend.log
# start frontend server, redirect stdout & stderr to logs/frontend.log
npm start > /home/ubuntu/logs/frontend.log 2>&1 &
