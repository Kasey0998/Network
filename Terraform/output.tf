output "instance_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.free_tier_instance.public_ip
}

output "instance_public_dns" {
  description = "The public DNS name of the EC2 instance"
  value       = aws_instance.free_tier_instance.public_dns
}
