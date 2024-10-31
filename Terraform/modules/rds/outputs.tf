output "instance" {
  value = aws_db_instance.postgres_db
}

output "rds_endpoint" {
  value = aws_db_instance.postgres_db.endpoint
}
