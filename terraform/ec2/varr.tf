variable "aws_access_key" {
  description = "AWS access key"
  type        = string
}

variable "aws_secret_key" {
  description = "AWS secret key"
  type        = string
}

variable "session_token" {
  description = "AWS session token"
  type        = string
}

variable "deployment_region" {
  description = "AWS deployment region"
  default     = "us-east-1" 
}

variable "ec2_type" {
  description = "Instance type for EC2"
  default     = "t2.micro"  
}

variable "ssh_key" {
  description = "Name of the SSH key pair"
  default     = "ec2key"  
}

variable "db_username" {
  description = "Database username"
  default     = "your_db_username"
}

variable "db_password" {
  description = "Database password"
  default     = "your_db_password"
}

variable "db_host" {
  description = "Public DNS of the database instance"
  type        = string
}

variable "db_port" {
  description = "Database port"
  default     = 5432
}


variable "public_key_path" {
  description = "Path to your SSH public key file"
  type        = string
}


variable "admin_ip" {
  description = "Admin IP address for SSH access"
  type        = string
}

