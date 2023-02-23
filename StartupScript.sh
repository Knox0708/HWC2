#!/bin/bash

# Install Java
yum update -y
yum install -y java-1.8.0-openjdk

# Install Logstash
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
echo "[logstash-7.x]
name=Elastic repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/oss-7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md" | tee /etc/yum.repos.d/logstash.repo
yum install -y logstash

# Install Filebeat
curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.14.1-x86_64.rpm
rpm -vi filebeat-7.14.1-x86_64.rpm

# Configure Logstash and Filebeat
cat << EOF > /etc/logstash/conf.d/logstash.conf
input {
  beats {
    port => 5044
  }
}

output {
  elasticsearch {
    hosts => ["localhost:9200"]
  }
}
EOF

cat << EOF > /etc/filebeat/filebeat.yml
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /var/log/*.log

output.elasticsearch:
  hosts: ["localhost:9200"]
EOF

# Enable and start Logstash and Filebeat services
systemctl enable logstash.service
systemctl start logstash.service
systemctl enable filebeat.service
systemctl start filebeat.service