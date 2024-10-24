#!/bin/bash
# script: setup_jenkins.sh
# author: Kenneth Postigo
# desc  :   install jenkins and start daemon process

# update repos
sudo apt update

# install jenkins dependencies
sudo apt install -y fontconfig openjdk-17-jre software-properties-common

# get jenkins download repo
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \
        https://pkg.jenkins.io/debian-stable binary/ | \
        sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# install jenkins
sudo apt install -y jenkins

# start and enable
sudo systemctl start jenkins
sudo systemctl enable jenkins

# verify
sudo systemctl status jenkins

