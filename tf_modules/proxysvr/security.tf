resource "aws_security_group" "proxy_sg" {
  name                  = "${var.app_shortcode}_proxysvr_sg"
  vpc_id                = var.vpc_id

  ingress {
    cidr_blocks         = var.source_cidr_blocks
    from_port           = 22
    to_port             = 22
    protocol            = "tcp"
  }

  dynamic "ingress" {
    for_each            = var.proxy_config.port_mappings
    content {
      cidr_blocks       = var.source_cidr_blocks
      from_port         = ingress.value.nlb_port
      to_port           = ingress.value.nlb_port
      protocol          = "tcp"
    }
  }

  egress {
    from_port           = 0
    to_port             = 0
    protocol            = "-1"
    cidr_blocks         = ["0.0.0.0/0"]
  }
  tags                  = var.common_tags
}

resource "aws_iam_role" "proxy_exec_role" {
  name_prefix           = "${var.app_shortcode}-proxysvr-exec-role"
  assume_role_policy    = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": [
          "ec2.amazonaws.com"
        ]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  
  depends_on            = [ aws_iam_policy.proxy_exec_role_permissions ]
  tags                  = var.common_tags
}

resource "aws_iam_policy" "proxy_exec_role_permissions" {
  name_prefix           = "${var.app_shortcode}-proxysvr-exec-role-permissions"
  description           = "Provides proxy EC2 instance access to other AWS services"

  policy = <<EOF
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
        "ssm:GetParameters"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "proxy_exec_role_policy" {
  role                  = aws_iam_role.proxy_exec_role.name
  policy_arn            = aws_iam_policy.proxy_exec_role_permissions.arn
}

resource "aws_iam_instance_profile" "proxy_instance_profile" {
  name_prefix           = "${var.app_shortcode}-proxysvr-instance-profile"
  role                  = aws_iam_role.proxy_exec_role.name

  depends_on            = [ aws_iam_role.proxy_exec_role ]
}

