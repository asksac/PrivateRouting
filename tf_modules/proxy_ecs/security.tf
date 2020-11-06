resource "aws_security_group" "proxy_sg" {
  name_prefix             = "${var.app_shortcode}-${var.proxy_config.service_name}-sg-"
  vpc_id                  = var.vpc_id

  egress {
    from_port             = 0
    to_port               = 0
    protocol              = "-1"
    cidr_blocks           = ["0.0.0.0/0"]
  }
  tags                    = var.common_tags
}

resource "aws_security_group_rule" "proxy_sg_rule" {
  for_each                = local.port_mappings_map

  type                    = "ingress"
  security_group_id       = aws_security_group.proxy_sg.id

  cidr_blocks             = var.source_cidr_blocks
  from_port               = each.value.proxy_port
  to_port                 = each.value.proxy_port
  protocol                = "tcp"
}

resource "aws_iam_role" "proxy_exec_role" {
  name                    = "${var.app_shortcode}-${var.proxy_config.service_name}-role"
  assume_role_policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "ecs-tasks.amazonaws.com", 
          "ec2.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  depends_on              = [ aws_iam_policy.proxy_exec_role_permissions ]
  tags                    = var.common_tags
}

resource "aws_iam_policy" "proxy_exec_role_permissions" {
  name                    = "${var.app_shortcode}-${var.proxy_config.service_name}-role-permissions"
  description             = "Provides ECS tasks access to AWS services such as ECR, CloudWatch, and SSM Parameter Store"

  policy                  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
        "logs:PutLogEvents", 
        "ssm:GetParameters", 
        "ecs:StartTelemetrySession"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "proxy_exec_role_policy" {
  role                    = aws_iam_role.proxy_exec_role.name
  policy_arn              = aws_iam_policy.proxy_exec_role_permissions.arn
}
