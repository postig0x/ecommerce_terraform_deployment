output "frontend_instance_id" {
  value = aws_instance.frontend[*].id
}

output "backend_sg_id" {
  value = aws_security_group.backend.id
}