resource "aws_security_group" "backend_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port               = 8080
    to_port                 = 8080
    protocol                = "tcp"
    # Autoriser le trafic depuis le groupe de sécurité frontend_sg
    security_groups         = [aws_security_group.frontend_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "frontend_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}




resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port               = 3306
    to_port                 = 3306
    protocol                = "tcp"
    security_groups         = [aws_security_group.backend_sg.id]  # Utilisez security_groups ici
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}





