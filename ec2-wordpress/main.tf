provider "aws" {
  region = "us-west-2"
}

# Key Pair
resource "tls_private_key" "key_pair" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "joinscaler_key_pair" {
  key_name   = "joinscaler-key"
  public_key = tls_private_key.key_pair.public_key_openssh
}

resource "local_file" "private_key_pem" {
  content  = tls_private_key.key_pair.private_key_pem
  filename = "private-key.pem"

  provisioner "local-exec" {
    command = "chmod 400 private-key.pem"
  }
}

# VPC
resource "aws_vpc" "joinscaler_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Joinscaler-VPC"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "joinscaler_igw" {
  vpc_id = aws_vpc.joinscaler_vpc.id

  tags = {
    Name = "Joinscaler-Internet-Gateway"
  }
}

# Subnet
resource "aws_subnet" "joinscaler_subnet" {
  vpc_id                  = aws_vpc.joinscaler_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "Joinscaler-Subnet"
  }
}

# Route Table
resource "aws_route_table" "joinscaler_route_table" {
  vpc_id = aws_vpc.joinscaler_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.joinscaler_igw.id
  }

  tags = {
    Name = "Joinscaler-Route-Table"
  }
}

# Route Table Association
resource "aws_route_table_association" "joinscaler_rta" {
  subnet_id      = aws_subnet.joinscaler_subnet.id
  route_table_id = aws_route_table.joinscaler_route_table.id
}

# Security Group
resource "aws_security_group" "joinscaler_sg" {
  name        = "joinscaler-security-group"
  description = "Security group for Joinscaler WordPress"
  vpc_id      = aws_vpc.joinscaler_vpc.id

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

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Joinscaler-Security-Group"
  }
}

# Elastic IP
resource "aws_eip" "joinscaler_eip" {
  domain = "vpc"

  tags = {
    Name = "Joinscaler-EIP"
  }
}

# EC2 Instance
resource "aws_instance" "joinscaler_ec2" {
  ami                         = "ami-0c02fb55956c7d316"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.joinscaler_subnet.id
  vpc_security_group_ids      = [aws_security_group.joinscaler_sg.id]
  key_name                    = aws_key_pair.joinscaler_key_pair.key_name
  associate_public_ip_address = true
  user_data                   = filebase64("${path.module}/wordpress.sh")

  root_block_device {
    volume_size = 20
    volume_type = "gp2"
    tags = {
      Name = "Joinscaler-Root-Volume"
    }
  }

  timeouts {
    create = "10m"
    delete = "10m"
  }

  tags = {
    Name        = "Joinscaler-EC2-2"
    Environment = "Production"
    Project     = "Joinscaler"
    Managed_by  = "Terraform"
  }
}

# Elastic IP Association
resource "aws_eip_association" "joinscaler_eip_association" {
  instance_id   = aws_instance.joinscaler_ec2.id
  allocation_id = aws_eip.joinscaler_eip.id
}