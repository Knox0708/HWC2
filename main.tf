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

    vpc_security_group_ids = [aws_security_group.Default.id]


  

  tags = {
    Name = "ExampleAppServerInstance"
  }
}

#Security Groups
resource "aws_security_group" "Default" {
  name_prefix = "Default"
  description = "Default security group"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["86.22.208.224/32"] #My IP?
  }
}

#Keys are below
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
  path = "*.log" #Need to add log.files
}

# Configure Logstash output
resource "logstash_output_file" "output" {
  path = "stashOutput.log"
}

# Configure Logstash pipeline
resource "logstash_pipeline" "Attempt" {
  config {
    input {
      plugin = logstash_input_file.input.id
    }
    output {
      plugin = logstash_output_file.output.id
    }
  }
}
