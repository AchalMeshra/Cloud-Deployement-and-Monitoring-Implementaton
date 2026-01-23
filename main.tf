terraform {
  backend "s3" {
    bucket = "my-terraform-state-devops-ac-bucket-016" # Pehle S3 bucket banayein console se
    key    = "devops-project/terraform.tfstate"
    region = "us-east-1"
    encrypt=true
  }
}


provider "aws" {
  region = "us-east-1"
}

# Day 3 logic: Automatic AMI search taaki Malformed error na aaye
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu) owner ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_instance" "web_server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_web.id]

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install nginx -y
              sudo systemctl start nginx
              EOF

  tags = {
    Name = "Day5-Final-Success"
  }
}

resource "aws_security_group" "allow_web" {
  name = "allow_web_day5_final"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "website_url" {
  value = "http://${aws_instance.web_server.public_ip}"
}


