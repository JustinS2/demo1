provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "justin-demo-vpc"
  cidr = "10.20.0.0/16"

  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnets  = ["10.20.101.0/24", "10.20.102.0/24", "10.20.103.0/24"]

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

output "vpc_module" {
  value = module.vpc
}
