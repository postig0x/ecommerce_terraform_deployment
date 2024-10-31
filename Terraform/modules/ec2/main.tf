resource "aws_security_group" "frontend" {
  vpc_id      = var.vpc_id
  name        = "frontend_sg"
  description = "frontend sg - SSH, React, Nodex"

  ## ssh
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "ssh"
  }

  ## react
  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
    description     = "react frontend"
    security_groups = [var.lb_sg_id]
  }

  ## http
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "http"
  }

  ## node exporter
  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "node exporter"
  }

  ## outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "frontend" {
  count                  = 2
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id[count.index]
  vpc_security_group_ids = [aws_security_group.frontend.id]
  key_name               = var.default_key_name
  user_data = templatefile(
    "${path.root}/../Scripts/frontend_setup.sh",
    {
      ssh_key            = var.ssh_key
      BACKEND_PRIVATE_IP = aws_instance.backend[count.index].private_ip
  })

  tags = {
    Name = "ecommerce_frontend_az${count.index + 1}"
  }

  depends_on = [aws_instance.backend]
}

resource "aws_security_group" "backend" {
  vpc_id      = var.vpc_id
  name        = "backend_sg"
  description = "backend sg - SSH, Django, Nodex"

  ## ssh
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "ssh"
  }

  ## django
  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "django backend"
  }

  ## node exporter
  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "node exporter"
  }

  ## outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "backend" {
  count                  = 2
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id[count.index]
  vpc_security_group_ids = [aws_security_group.backend.id]
  key_name               = var.default_key_name
  user_data = templatefile(
    "${path.root}/../Scripts/backend_setup.sh",
    {
      db_name      = var.db_name,
      db_username  = var.db_username,
      db_password  = var.db_password,
      rds_endpoint = var.rds_endpoint,
      migrate      = count.index == 0 ? true : false,
  })

  tags = {
    Name = "ecommerce_backend_az${count.index + 1}"
  }

  depends_on = [var.rds_instance]
}
