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










