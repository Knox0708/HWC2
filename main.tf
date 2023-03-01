terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
    # logstash = {
    #   source  = "hashicorp/logstash"
    #   version = "3.0.0"
    #  }
  }

  required_version = ">= 1.2.0"
}



provider aws {
  region     = "us-east-1"
    # access_key = AKIAS5SKF73IX2I4LXFR # Might need .aws_access_key
    # secret_key = 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 # Might need .aws_secret_key
}


resource "aws_instance" "Server" {
  ami           = "ami-0aa7d40eeae50c9a9"
  instance_type = "t3.medium"
  key_name = "tf-key-pair"
  user_data = file("StartupScript.sh")
  vpc_security_group_ids = [aws_security_group.Default.id]
  

   tags = {
    Name = "AppServerInstance"
  }


}

#Security Groups
resource "aws_security_group" "Default" {
  name_prefix = "Default"
  description = "Default security group"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
    ingress {
    description = "ESearch"
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

      ingress {
    description = "Kibana"
    from_port   = 5601
    to_port     = 5601
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   
    ingress {
    description = "FBeat"
    from_port   = 5044
    to_port     = 5044
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
   
  #outbound rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # egress {
  #   description = "FBeat"
  #   from_port   = 5044
  #   to_port     = 5044
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  #}
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






#JVM options - to change the amount of memory used by Logstash (should be small)