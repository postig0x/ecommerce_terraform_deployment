# rds subnet group
#
#
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [for subnet_id in var.private_subnet_id : subnet_id]

  tags = {
    Name = "RDS subnet group"
  }
}

# rds security group
#
#
resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "security group for RDS"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.backend_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS Security Group"
  }
}

# rds instance
#
#
resource "aws_db_instance" "postgres_db" {
  identifier           = "ecommerce-db"
  engine               = "postgres"
  engine_version       = "14.13"
  instance_class       = var.db_instance_class
  allocated_storage    = 20
  storage_type         = "standard"
  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password
  parameter_group_name = "default.postgres14"
  skip_final_snapshot  = true

  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  tags = {
    Name = "Ecommerce Postgres DB"
  }
}
