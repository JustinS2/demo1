provider "aws" {
  region = "us-east-1"
}

variable "my_vpc" {}
variable "my_security_groups" {}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"
  name = "justin-demo-alb"
  load_balancer_type = "application"
  enable_cross_zone_load_balancing = true

  vpc_id             = var.my_vpc.vpc_id
  subnets            = var.my_vpc.public_subnets
  security_groups    = var.my_security_groups

  target_groups = [
  # Must retain order
    {
      name_prefix      = "jdemo-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    },
    {
      name_prefix      = "gdemo-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    },
    {
      name_prefix      = "bdemo-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]
  tags = {
    Environment = "Test"
  }
}

resource "aws_lb_listener_rule" "green" {
  listener_arn = module.alb.http_tcp_listener_arns[0]
  
  action {
    type             = "forward"
    target_group_arn = module.alb.target_group_arns[1]
  }
  condition {
    path_pattern {
      values = ["/green*"]
    }
  }
}

resource "aws_lb_listener_rule" "blue" {
  listener_arn = module.alb.http_tcp_listener_arns[0]

  action {
    type             = "forward"
    target_group_arn = module.alb.target_group_arns[2]
  }
  condition {
    path_pattern {
      values = ["/blue*"]
    }
  }
}


output "my_alb" {
  value = module.alb
}
