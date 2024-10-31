variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_availability_zones" {
  description = "Availability zones for subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "ec2_instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID - Ubuntu 24.04 LTS (x86_64)"
  type        = string
  default     = "ami-0866a3c8686eaeeba"
}

variable "default_key_name" {
  description = "default key name to be used in EC2s"
  type        = string
}

variable "ssh_key" {
  description = "private key for private instance access"
  type        = string
}

variable "db_instance_class" {
  description = "The instance type of the RDS instance"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "The name of the database to create when the DB instance is created"
  type        = string
  default     = "ecommercedb"
}

variable "db_username" {
  description = "Username for the master DB user"
  type        = string
  default     = "kurac5user"
}

variable "db_password" {
  description = "Password for the master DB user"
  type        = string
  default     = "kurac5password"
}

