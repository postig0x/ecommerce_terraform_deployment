terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.73.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source     = "./modules/vpc"
  vpc_name   = "wl5vpc"
  cidr_block = var.vpc_cidr
}

module "subnet" {
  source             = "./modules/subnet"
  vpc_id             = module.vpc.id
  availability_zones = var.subnet_availability_zones
  vpc_cidr_block     = module.vpc.cidr_block
}

module "ec2" {
  source            = "./modules/ec2"
  vpc_id            = module.vpc.id
  lb_sg_id          = module.alb.sg_id
  public_subnet_id  = module.subnet.public_subnet_id
  private_subnet_id = module.subnet.private_subnet_id
  instance_type     = var.ec2_instance_type
  ami_id            = var.ami_id
  default_key_name  = var.default_key_name
  ssh_key           = var.ssh_key
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
  rds_endpoint      = module.rds.rds_endpoint
  rds_instance      = module.rds.instance
}

module "alb" {
  source               = "./modules/load_balancer"
  vpc_id               = module.vpc.id
  public_subnet_id     = module.subnet.public_subnet_id
  frontend_instance_id = module.ec2.frontend_instance_id
}

module "rds" {
  source            = "./modules/rds"
  db_instance_class = var.db_instance_class
  db_name           = var.db_name
  db_username       = var.db_username
  db_password       = var.db_password
  private_subnet_id = module.subnet.private_subnet_id
  vpc_id            = module.vpc.id
  backend_sg_id     = module.ec2.backend_sg_id
}
