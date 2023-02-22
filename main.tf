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
    # secret_key = FyvGStLJJHu4suNuNdknhdon6e6ls6Ugzt1YPd8D # Might need .aws_secret_key
}


resource "aws_instance" "example" {
  ami           = "ami-2757f631"
  instance_type = "t2.micro"
  key_name = "tf-key-pair"
  user_data = file("LogstashInstall.sh")

    # vpc_security_group_ids = [aws_security_group.Default.id]
  

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

    egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["86.22.208.224/32"]
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




# resource "local_file" "logstash_config" {
#   content  = <<EOF
# input {
#   file {
#     path => "/var/log/nginx/access.log"
#   }
# }
# output {
#   file {
#     path => "/var/log/logstash/access.log"
#   }
# }
# EOF
#   filename = "logstash.conf"
# }

# resource "aws_ssm_parameter" "logstash_config" {
#   name  = "/logstash/config"
#   type  = "String"
#   value = local_file.logstash_config.content
# }



#JVM options - to change the amount of memory used by Logstash (should be small)