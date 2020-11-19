provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

variable "my_vpc" {}

resource "aws_security_group" "allow_http_all" {
  name        = "allow_http_all"
  description = "Allow HTTP inbound traffic"
  vpc_id      = var.my_vpc.vpc_id

  ingress {
    description = "HTTP allow all"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http"
  }
}

output "allow_http_id" {
 value = aws_security_group.allow_http_all.id
}

resource "aws_security_group" "allow_ssh_all" {
  name        = "allow_ssh_all"
  description = "Allow  SSH inbound traffic"
  vpc_id      = var.my_vpc.vpc_id

  ingress {
    description = "SSH allow all"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_http_ssh"
  }
}

output "allow_ssh_id" {
 value = aws_security_group.allow_ssh_all.id
}

resource "aws_security_group" "allow_alb_sg" {
  name        = "allow_alb_sg"
  description = "Allow inbound traffic from ALBs sg"
  vpc_id      = var.my_vpc.vpc_id

  ingress {
    description = "HTTP allow from ALB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.allow_http_all.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_alb"
  }
}

output "allow_alb_id" {
 value = aws_security_group.allow_alb_sg.id
}