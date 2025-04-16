data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"

  name = "example-part-2"
  cidr = var.vpc_cidr

  azs             = var.subnet_azs 
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  enable_nat_gateway = true

  tags = var.tags
}