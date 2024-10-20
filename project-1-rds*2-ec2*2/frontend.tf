resource "aws_instance" "frontend" {
  ami             = "ami-0d64bb532e0502c46" # Remplacez par un ID d'AMI valide
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.public_a.id
  vpc_security_group_ids = [aws_security_group.frontend_sg.id]  # Utilisez vpc_security_group_ids

  # Script d'installation de Nginx
  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install nginx -y
              sudo systemctl start nginx
              sudo systemctl enable nginx
              EOF

  tags = {
    Name = "Frontend"
  }
}

# Elastic IP resource for the frontend instance
resource "aws_eip" "frontend_ip" {
  instance = aws_instance.frontend.id
}
