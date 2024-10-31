# load balancer security group
#
#
resource "aws_security_group" "lb_sg" {
  vpc_id = var.vpc_id

  ## http
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

  tags = {
    Name = "lb_sg"
  }
}

# load balancer
#
#
resource "aws_lb" "frontend_lb" {
  name               = "frontend-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [for subnet_id in var.public_subnet_id : subnet_id]

  enable_deletion_protection = false

  tags = {
    Name = "frontend-lb"
  }
}

# load balancer target group
#
#
resource "aws_lb_target_group" "frontend_tg" {
  name     = "frontend-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "frontend-tg"
  }
}

# load balancer listener
#
#
resource "aws_lb_listener" "frontend_listener" {
  load_balancer_arn = aws_lb.frontend_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend_tg.arn
  }
}

# register ec2 instances with target group
#
#
resource "aws_lb_target_group_attachment" "frontend_attachment" {
  count            = 2
  target_group_arn = aws_lb_target_group.frontend_tg.arn
  target_id        = var.frontend_instance_id[count.index]
  port             = 3000
}
