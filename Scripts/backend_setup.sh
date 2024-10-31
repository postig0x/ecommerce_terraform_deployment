#!/bin/bash
# backend_setup.sh

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

BACKEND_PRIVATE_IP=$(hostname -i | awk '{print $1}')
# setup backend config
sed -i "s/ALLOWED_HOSTS = \[\]/ALLOWED_HOSTS = \[\"$BACKEND_PRIVATE_IP\"\]/" /home/ubuntu/deployment/backend/my_project/settings.py

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

#            _   _
#  _ __ _  _| |_| |_  ___ _ _
# | '_ \ || |  _| ' \/ _ \ ' \
# | .__/\_, |\__|_||_\___/_||_|
# |_|   |__/
# install
sudo add-apt-repository ppa:deadsnakes/ppa
sudo apt install -y python3.9 python3.9-venv python3.9-dev

# virtual environment
cd /home/ubuntu/deployment/backend
python3.9 -m venv venv
source venv/bin/activate

# install requirements
pip install -r requirements.txt

#     _  _
#  __| |(_)__ _ _ _  __ _ ___
# / _` || / _` | ' \/ _` / _ \
# \__,_|/ \__,_|_||_\__, \___/
#     |__/          |___/
# configure RDS DB in settings.py
sed -i "s/#\s*'NAME': 'your_db_name'/'NAME': '${db_name}'/g" /home/ubuntu/deployment/backend/my_project/settings.py

sed -i "s/#\s*'USER': 'your_username'/'USER': '${db_username}'/g" /home/ubuntu/deployment/backend/my_project/settings.py

sed -i "s/#\s*'PASSWORD': 'your_password'/'PASSWORD': '${db_password}'/g" /home/ubuntu/deployment/backend/my_project/settings.py

rds_endpoint_noport=$(echo "${rds_endpoint}" | sed 's/:.*//')

sed -i "s/#\s*'HOST': 'your-rds-endpoint.amazonaws.com'/'HOST': '$rds_endpoint_noport'/g" /home/ubuntu/deployment/backend/my_project/settings.py

# remove comments
sed -i "s/#\s*'ENGINE': 'django.db.backends.postgresql'/'ENGINE': 'django.db.backends.postgresql'/g" /home/ubuntu/deployment/backend/my_project/settings.py

sed -i "s/#\s*'PORT': '5432'/'PORT': '5432'/g" /home/ubuntu/deployment/backend/my_project/settings.py

sed -i "s/#\s*},/},/g" /home/ubuntu/deployment/backend/my_project/settings.py

sed -i "s/#\s*'sqlite': {/'sqlite': {/g" /home/ubuntu/deployment/backend/my_project/settings.py

# FIX: backend/account/models.py:StripeModel.card_number needs larger char count
sed -i "s/card_number = models.CharField(max_length=16/card_number = models.CharField(max_length=24/" /home/ubuntu/deployment/backend/account/models.py

# create tables in rds
cd /home/ubuntu/deployment/backend/
python manage.py makemigrations account
python manage.py makemigrations payments
python manage.py makemigrations product
python manage.py migrate

# migrate from SQLite to RDS for the first instance only
if [[ ${migrate} ]]
then
  python manage.py dumpdata \
  --database=sqlite \
  --natural-foreign \
  --natural-primary \
  -e contenttypes -e auth.Permission \
  --indent 4 > datadump.json
  
  python manage.py loaddata datadump.json
fi

# Start Django Server
mkdir -p /home/ubuntu/logs && touch /home/ubuntu/logs/backend.log
python manage.py runserver 0.0.0.0:8000 > /home/ubuntu/logs/backend.log 2>&1 &
