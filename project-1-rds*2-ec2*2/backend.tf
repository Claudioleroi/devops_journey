resource "aws_instance" "backend" {
  ami             = "ami-0d64bb532e0502c46" # Remplacez par un ID d'AMI valide
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.private_a.id
  vpc_security_group_ids = [aws_security_group.backend_sg.id]  # Utilisez vpc_security_group_ids

  tags = {
    Name = "Backend"
  }
}