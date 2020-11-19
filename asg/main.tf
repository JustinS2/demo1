provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

variable "public_subnets" {}
variable "security_groups" {}
variable "alb_prod_target" {}
variable "color" {}
variable "active" {}
variable "ami" {}
variable "load_balancer" {}

resource "aws_placement_group" "justin-demo-pg" {
  name     = "justin-demo-pg-${var.color}"
  strategy = "partition"
}

resource "aws_launch_template" "justin-demo-lt" {
  name_prefix = "justin-demo-lt-${var.color}"
  image_id           = var.ami
  instance_type      = "t2.micro"
  vpc_security_group_ids    = var.security_groups
}

resource "aws_autoscaling_policy" "justin-demo-scale-alb-req" {
  count = var.active ? 1 : 0
  name                   = "alb-demand-scaling-${var.color}"
  policy_type            = "TargetTrackingScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.justin-demo-web-asg.name
  target_tracking_configuration {
    predefined_metric_specification {
#      predefined_metric_type = "ASGAverageCPUUtilization"
      predefined_metric_type = "ALBRequestCountPerTarget"
      resource_label         = "${var.load_balancer.this_lb_arn_suffix}/${var.load_balancer.target_group_arn_suffixes[0]}"
    }
    target_value = 100
  }
}

resource "aws_autoscaling_policy" "justin-demo-scale-cpu" {
  count = var.active ? 0 : 1
  name                   = "cpu-scaling-${var.color}"
  policy_type            = "TargetTrackingScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.justin-demo-web-asg.name
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 20
  }
}

resource "aws_autoscaling_group" "justin-demo-web-asg" {
  name                      = "jtest-asg-${var.color}"
  max_size                  = 10
  min_size                  = 1
  health_check_grace_period = 60
  health_check_type         = "EC2"
  force_delete              = true
  launch_template {
    id      = aws_launch_template.justin-demo-lt.id
    version = "$Latest"
  }
  vpc_zone_identifier  = var.public_subnets
  target_group_arns = ["${var.active == true ? var.load_balancer.target_group_arns[0] : "" }", "${var.color == "green" ? var.load_balancer.target_group_arns[1] : var.load_balancer.target_group_arns[2] }"]
  termination_policies = ["OldestLaunchTemplate"]

  tag {
    key                 = "env"
    value               = var.color
    propagate_at_launch = true
  }

  timeouts {
    delete = "15m"
  }
}
