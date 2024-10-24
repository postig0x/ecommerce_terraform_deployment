#!/bin/bash
# script: setup_tf.sh
# author: Kenneth Postigo
# desc  : install terraform

# dependencies
sudo apt update
sudo apt install -y gnupg software-properties-common

# hashicorp gpg key
wget -O- https://apt.releases.hashicorp.com/gpg | \
        gpg --dearmor | \
        sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

# verify fingerprint
gpg --no-default-keyring \
        --keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
        --fingerprint

# add hashicorp repo
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
        https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
        sudo tee /etc/apt/sources.list.d/hashicorp.list

# download hashicorp repo info
sudo apt update

# install terraform
sudo apt install -y terraform

