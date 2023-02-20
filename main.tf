terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}



provider aws {
  region     = "us-east-1"
}

resource "aws_instance" "example" {
  ami           = "ami-2757f631"
  instance_type = "t2.micro"
  key_name = "tf-key-pair"
  user_data = file("LogstashInstall.sh")

  

  tags = {
    Name = "ExampleAppServerInstance"
  }
}

resource "aws_key_pair" "tf-key-pair" {
key_name = "tf-key-pair"
public_key = tls_private_key.rsa.public_key_openssh
}
resource "tls_private_key" "rsa" {
algorithm = "RSA"
rsa_bits  = 4096
}
resource "local_file" "tf-key-pair" {
content  = tls_private_key.rsa.private_key_pem
filename = "tf-key-pair"
}

# Configure Logstash input
resource "logstash_input_file" "input" {
  path = "/path/to/input/folder/*.log" #Need to add log.files
}

# Configure Logstash output
resource "logstash_output_file" "output" {
  path = "/path/to/output/folder/output.log"
}

# Configure Logstash pipeline
resource "logstash_pipeline" "example" {
  config {
    input {
      plugin = logstash_input_file.input.id
    }
    output {
      plugin = logstash_output_file.output.id
    }
  }
}
