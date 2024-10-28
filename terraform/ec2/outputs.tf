output "app_instance_public_ip" {
  description = "Public IPs of the app instances"
  value       = aws_instance.app[*].public_ip
}

output "db_instance_public_ip" {
  description = "Public IP of the database instance"
  value       = aws_instance.db.public_ip
}

output "db_instance_private_ip" {
  description = "Private IP of the database instance"
  value       = aws_instance.db.private_ip
}
