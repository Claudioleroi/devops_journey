output "frontend_ip" {
  value       = aws_eip.frontend_ip.public_ip
  description = "The public IP of the frontend server"
}

output "frontend_instance_id" {
  value       = aws_instance.frontend.id
  description = "The ID of the frontend instance"
}

output "backend_instance_id" {
  value       = aws_instance.backend.id
  description = "The ID of the backend instance"
}

output "db_instance_endpoint" {
 value       = [for i in aws_db_instance.database : i.endpoint] 
  description = "The endpoints of the database instances"
}
