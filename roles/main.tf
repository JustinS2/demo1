resource "aws_iam_role" "justin-demo-cw" {
  name = "justin_demo_ec2_cw"


  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "justin_demo_profile" {
  name = "justin_demo_ec2_profile"
  role = "${aws_iam_role.justin-demo-cw.name}"
}

resource "aws_iam_role_policy" "justin-policy" {
  name = "justin-demo-policy-ec2"
  role = aws_iam_role.justin-demo-cw

  policy = <<EOF
    { 
    "Version": "2012-10-17",
    "Statement": [ tags = {
        { tag-key = "tag-value"
            "Action": [ }
                "autoscaling:Describe*",}
                "cloudwatch:*",
                "logs:*",
                "sns:*",
                "iam:GetPolicy",
                "iam:GetPolicyVersion",
                "iam:GetRole"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "arn:aws:iam::*:role/aws-service-role/events.amazonaws.com/AWSServiceRoleForCloudWatchEvents*",
            "Condition": {
                "StringLike": {
                    "iam:AWSServiceName": "events.amazonaws.com"
                }
            }
        }
    ]
  }
EOF
}

output "ec2-profile" {
  value = aws_iam_instance_profile.justin_demo_profile
}
