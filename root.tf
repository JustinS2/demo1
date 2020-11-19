provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

module "vpc" {
  source = "./vpc"
}

data "aws_security_groups" "default_sg" {
  filter {
    name = "vpc-id"
    values = [module.vpc.vpc_module.vpc_id]
  }
  filter {
    name = "group-name"
    values = ["default"]
  }
}

module "sgs" {
  source = "./sgs"
  my_vpc = module.vpc.vpc_module
}

module "alb" {
  source = "./alb"
  my_vpc = module.vpc.vpc_module
  my_security_groups = [module.sgs.allow_http_id]
}

# module "iam_role" {
#   source = "./roles"
# }

# blue
module "asg-blue" {
  source = "./asg"
  public_subnets = module.vpc.vpc_module.public_subnets
  security_groups = [module.sgs.allow_ssh_id, module.sgs.allow_alb_id, data.aws_security_groups.default_sg.ids[0]]
  alb_prod_target = module.alb.my_alb.target_group_arns[0]
  load_balancer = module.alb.my_alb
  color = "blue"
  active = true
  ami = "ami-09beaf225d2fbcb84"
}

# green
module "asg-green" {
  source = "./asg"
  public_subnets = module.vpc.vpc_module.public_subnets
  security_groups = [module.sgs.allow_ssh_id, module.sgs.allow_alb_id, data.aws_security_groups.default_sg.ids[0]]
  alb_prod_target = module.alb.my_alb.target_group_arns[0]
  load_balancer = module.alb.my_alb
  color = "green"
  active = false
  ami = "ami-0aa5a4457b106685b"
}

# output "role" {
#   value = module.iam_role
# }