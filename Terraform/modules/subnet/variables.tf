variable "vpc_id" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "vpc_cidr_block" {
  type = string
}
