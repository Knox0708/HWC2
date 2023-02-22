#!/bin/bash

chmod +x /path/to/logstashInstall.sh


#This is a script to install Logstash

# /Users/Michael.Knox/documents/HWC2/Logstash/LogstashInstall.sh



echo "Installing Logstash Public Signing Key"
sudo wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo gpg --dearmor -o /usr/share/keyrings/elastic-keyring.gpg


echo "Debian Key"
sudo apt-get install apt-transport-https

echo "Saving Repo Definition"
echo "deb [signed-by=/usr/share/keyrings/elastic-keyring.gpg] https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-8.x.list

echo "Updating repo and Installing logstash"
sudo apt-get update && sudo apt-get install logstash


