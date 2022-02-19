# A VPC for the Alloy App

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.2.0"

  name                 = "${var.name}-${var.environment}"
  cidr                 = "10.0.0.0/16"
  azs                  = data.aws_availability_zones.available.names
  private_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets       = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  tags = {
    "environment" = "${var.environment}"
    "client"      = "${var.name}"
  }

  public_subnet_tags = {
    "name" = "${var.name}-${var.environment}-public"
  }

  private_subnet_tags = {
    "name" =  "${var.name}-${var.environment}-private"
  }
}


