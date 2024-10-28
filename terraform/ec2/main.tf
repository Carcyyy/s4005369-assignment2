hcl
Copy code
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"  
    }
  }
}
  backend "s3" {
    bucket         = "terraform-state-bucket-carcy" 
    key            = "terraform/app/terraform.tfstate" 
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"  
  }
}

provider "aws" {
  region = "us-east-1"
}

# Obtain the latest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# SSH key pair
resource "aws_key_pair" "deployer" {
  key_name   = "carcy-key"
  public_key = file(var.public_key_path)
}

# Security Group Configuration
resource "aws_security_group" "vm_inbound" {
  name        = "vm_inbound"
  description = "Allow inbound traffic for app and db servers"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_ip]  # Restrict SSH to your admin IP
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # Allow PostgreSQL access from within the subnet
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Application EC2 Instances
resource "aws_instance" "app" {
  count           = 2
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.vm_inbound.name]

  tags = {
    Name = "foo-app-server-${count.index + 1}"
  }
}

# Database EC2 Instance
resource "aws_instance" "db" {
  ami             = data.aws_ami.ubuntu.id
  instance_type   = "t2.micro"
  key_name        = aws_key_pair.deployer.key_name
  security_groups = [aws_security_group.vm_inbound.name]

  tags = {
    Name = "foo-db-server"
  }
}