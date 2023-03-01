

#!/bin/bash



# Install Java
yum update -y
yum install -y java-1.8.0-openjdk

# Install Elasticsearch
rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
tee /etc/yum.repos.d/elasticsearch.repo <<EOF
[elasticsearch-7.x]
name=Elasticsearch repository for 7.x packages
baseurl=https://artifacts.elastic.co/packages/7.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md
EOF
yum install -y elasticsearch

#Install Kibana
yum install kibana -y

# Get private IP address of the instance
PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)

# Configure Elasticsearch
sed -i 's/#network.host: 192.168.0.1/network.host: 0.0.0.0/g' /etc/elasticsearch/elasticsearch.yml
sed -i "/^#cluster.initial_master_nodes:/a cluster.initial_master_nodes: ['$(hostname -f)']" /etc/elasticsearch/elasticsearch.yml

# Set up ILM policy to remove replicas after 1 day
cat <<EOF > /etc/elasticsearch/ilm_policy.json
{
  "policy": {
    "phases": {
      "hot": {
        "actions": {
          "rollover": {
            "max_age": "1d",
            "max_size": "50gb"
          }
        }
      },
      "delete": {
        "actions": {
          "delete": {}
        }
      }
    }
  }
}
EOF

# sed -i 's/#discovery.seed_hosts: \[\"127.0.0.1\",\"\[::1\]\"\]/discovery.seed_hosts: ["localhost"]/' /etc/elasticsearch/elasticsearch.yml
# echo "discovery.type: single-node" >> /etc/elasticsearch/elasticsearch.yml
systemctl daemon-reload
systemctl enable elasticsearch.service
systemctl start elasticsearch.service

#Config Kibana
kibanayaml="server.port: 5601
server.host: '0.0.0.0'

elasticsearch.hosts: ['http://localhost:9200']
elasticsearch.username: 'elastic'
elasticsearch.password: 'password'
"
echo "$kibanayaml" > /etc/kibana/kibana.yml

# Enable and start Kibana service
systemctl daemon-reload
systemctl enable kibana.service
systemctl start kibana.service

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

# Configure Pipelines
cat << EOF > /etc/logstash/pipelines.yml
- pipeline.id: logs1
  path.config: "/etc/logstash/conf.d/logs1.conf"
- pipeline.id: logs2
  path.config: "/etc/logstash/conf.d/logs2.conf"
- pipeline.id: logs3
  path.config: "/etc/logstash/conf.d/logs3.conf"
EOF

# Configure Logstash and Filebeat
cat << EOF > /etc/logstash/conf.d/logs1.conf
input {
  beats {
    port => 5044
  }
}

filter {
  grok {
    match => { "message" => "Hello World" }
}

}
output {
  elasticsearch {
    hosts => ["localhost:9200"]
  }
}
EOF

cat << EOF > /etc/logstash/conf.d/logs2.conf
input {
  beats {
    port => 5044
  }
}

filter {
  grok {
    match => { "message" => "Hello World" }
}

}
output {
  elasticsearch {
    hosts => ["localhost:9200"]
  }
}
EOF

cat << EOF > /etc/logstash/conf.d/logs3.conf
input {
  beats {
    port => 5044
  }
}

filter {
  grok {
    match => { "message" => "Hello World" }
}

}
output {
  elasticsearch {
    hosts => ["localhost:9200"]
  }
}
EOF


#Filebeat yml
cat << EOF > /etc/filebeat/filebeat.yml
filebeat.inputs:
- type: filestream
  enabled: true
  paths:
    - /etc/logstash/inputHW.log
output.logstash:
  hosts: ["localhost:5044"]
EOF


# Enable and start Logstash and Filebeat services
systemctl enable logstash.service
systemctl start logstash.service
systemctl enable filebeat.service
systemctl start filebeat.service

#Setup Output File

#Insert log
echo "Hello World" > /etc/logstash/inputHW.log
chmod 777 /var/log/inputHW.log

#Setup Output File
touch /etc/logstash/outputHW.log