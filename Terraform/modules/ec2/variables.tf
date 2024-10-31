variable "vpc_id" {
  type = string
}

variable "lb_sg_id" {
  type = string
}

variable "public_subnet_id" {
  type = list(string)
}

variable "private_subnet_id" {
  type = list(string)
}

variable "instance_type" {
  type = string
}

variable "ami_id" {
  type = string
}

variable "default_key_name" {
  type = string
}

variable "ssh_key" {
  type = string
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type = string
}

variable "rds_endpoint" {
  type = string
}

variable "rds_instance" {
  type = any
}
