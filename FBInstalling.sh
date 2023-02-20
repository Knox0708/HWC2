#!/bin/bash


cat >> FilebeatInstall.sh <<EOF
echo "Installing Beats Public Signing Key"
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

echo "Debian"
sudo apt-get install apt-transport-https

echo "Saving repo definition"
echo "deb https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-8.x.list

echo "Installing Filebeat"
sudo apt-get update && sudo apt-get install filebeat

echo "configuring auto-boot"
sudo systemctl enable filebeat' 
EOF


echo "Running FilbeatInstall.sh"
/bin/bash FilebeatInstall.sh /Terraform/FilebeatInstall.sh



