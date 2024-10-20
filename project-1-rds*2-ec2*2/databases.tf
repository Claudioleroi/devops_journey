resource "aws_db_instance" "database" {
    count = 2
  allocated_storage    = 20
  engine              = "mysql"
  engine_version      = "8.0"
  instance_class      = "db.t3.micro"

  username            = "admin"
  password            = var.db_password
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  db_subnet_group_name = aws_db_subnet_group.db_subnets.name

  # Ajoutez ces lignes pour le snapshot final
  skip_final_snapshot = false
  final_snapshot_identifier = "my-final-snapshot-${count.index}" # Personnalisez selon vos besoins

  tags = {
    Name = "Database ${count.index}"
  }
}


resource "aws_db_subnet_group" "db_subnets" {
  name       = "db_subnet_group"
  subnet_ids = [aws_subnet.private_a.id, aws_subnet.private_b.id]
}
