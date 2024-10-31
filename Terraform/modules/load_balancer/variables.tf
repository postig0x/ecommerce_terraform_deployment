variable "vpc_id" {
  type = string
}

variable "public_subnet_id" {
  type = list(string)
}

variable "frontend_instance_id" {
  type = list(string)
}
