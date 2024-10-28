terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket         = "terraform-state-bucket-carcy" 
    key            = "terraform/app/terraform.tfstate" 
    region         = "us-east-1"
  }
}

provider "aws" {
  region  = "us-east-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_key_pair" "deployer" {
  key_name   = "carcy-key"  
  public_key = file(var.public_key_path)
}

resource "aws_security_group" "vm_inbound" {
  name        = "vm_inbound"
  description = "Allow inbound traffic for app and db servers"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app" {
  count           = 2
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.vm_inbound.name]
}

resource "aws_instance" "db" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.vm_inbound.name]
}

output "app_instance_public_ip" {
  value = aws_instance.app[*].public_ip
}

output "db_instance_public_ip" {
  value = aws_instance.db.public_ip
}
