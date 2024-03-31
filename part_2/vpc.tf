data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.7.0"

  name = "example-part-2"
  cidr = "10.0.0.0/16"

  azs             = ["ca-central-1a", "ca-central-1b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true

  tags = {
    managed-by = "Terraform"
  }
}