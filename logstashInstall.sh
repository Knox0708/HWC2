#!/bin/bash

#This is a script to install Logstash

# /Users/Michael.Knox/documents/HWC2/Logstash/LogstashInstall.sh

echo "Installing Yum"
sudo yum update -y
sudo yum install -y java-1.8.0-openjdk
java -version

echo "importing signing key"
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch




echo "Logging into sudo"
sudo su

echo "Downloading Logstash"
sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch


echo "Adding Repo File"

sudo vim /etc/yum.repos.d/logstash.repo
[logstash-8.x]
name=Elastic repository for 8.x packages
baseurl=https://artifacts.elastic.co/packages/8.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md

cat /etc/yum.repos.d/logstash.repo

echo "installing Logstash onto EC2"

sudo yum install -y logstash

echo "starting Logstash"
sudo systemctl start logstash
