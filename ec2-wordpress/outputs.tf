output "private_key" {
  value     = tls_private_key.key_pair.private_key_pem
  sensitive = true
}

output "public_ip" {
  value = aws_eip.joinscaler_eip.public_ip
  description = "The public IP address of the WordPress server"
}

output "instance_id" {
  value = aws_instance.joinscaler_ec2.id
  description = "The ID of the EC2 instance"
}

output "vpc_id" {
  value = aws_vpc.joinscaler_vpc.id
  description = "The ID of the VPC"
}

output "subnet_id" {
  value = aws_subnet.joinscaler_subnet.id
  description = "The ID of the subnet"
}

output "security_group_id" {
  value = aws_security_group.joinscaler_sg.id
  description = "The ID of the security group"
}

output "ssh_command" {
  value = "ssh -i private-key.pem ubuntu@${aws_eip.joinscaler_eip.public_ip}"
  description = "Command to SSH into the instance"
}


