#Local Files for VM

resource "local_file" "logstash_config" {
  content  = <<EOF
input {
  file {
    path => "/var/log/nginx/access.log"
  }
}
output {
  file {
    path => "/var/log/logstash/access.log"
  }
}
EOF
  filename = "logstash.conf"
}


resource "aws_ssm_parameter" "logstash_config" {
  name  = "/logstash/config"
  type  = "String"
  value = local_file.logstash_config.content
}

resource "local_file" "logstash_install" {
  content  = <<EOF
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


EOF
  filename = "logstashInstall.sh"
}

resource "local_file" "filebeat_config" {
  content  = <<-EOF
    filebeat.inputs:
    - type: log
      paths:
        - /var/log/nginx/access.log
    
    output.elasticsearch:
      hosts: ["localhost:9200"]
  EOF
  filename = "filebeat.yml"
}

resource "aws_ssm_parameter" "filebeat_config" {
  name  = "/filebeat/config"
  type  = "String"
  value = local_file.filebeat_config.content
}

resource "null_resource" "install_filebeat" {
  provisioner "local-exec" {
    command = <<EOF
    echo "Installing filebeat"
    sudo apt-get update && sudo apt-get install filebeat
    sudo systemctl enable filebeat.service
    sudo systemctl start filebeat.service
    EOF
  }
  depends_on = [
    aws_ssm_parameter.filebeat_config,
  ]
}


