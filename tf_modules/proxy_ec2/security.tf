resource "aws_security_group" "proxy_sg" {
  name_prefix             = "${var.app_shortcode}-${var.proxy_config.service_name}-sg-" # sg name can be 255 char long
  vpc_id                  = var.vpc_id

  egress {
    from_port             = 0
    to_port               = 0
    protocol              = "-1"
    cidr_blocks           = ["0.0.0.0/0"]
  }
  tags                    = var.common_tags
}

# rule to allow ssh access to proxy ec2 instances if enabled
resource "aws_security_group_rule" "proxy_sg_ssh_rule" {
  count                   = var.ec2_ssh_enabled ? 1 : 0
  
  type                    = "ingress"
  security_group_id       = aws_security_group.proxy_sg.id

  cidr_blocks             = var.ssh_source_cidr_blocks
  from_port               = 22
  to_port                 = 22
  protocol                = "tcp"
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
  name_prefix             = "${var.app_shortcode}-${var.proxy_config.service_name}-exec-role-"
  assume_role_policy      = <<EOF
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
  
  depends_on              = [ aws_iam_policy.proxy_exec_role_permissions ]
  tags                    = var.common_tags
}

resource "aws_iam_policy" "proxy_exec_role_permissions" {
  name_prefix             = "${var.app_shortcode}-${var.proxy_config.service_name}-exec-role-permissions-"
  description             = "Provides proxy instance access to other AWS services"

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
        "ssm:GetParameters"
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

resource "aws_iam_instance_profile" "proxy_instance_profile" {
  name_prefix             = "${var.app_shortcode}-${var.proxy_config.service_name}-instance-profile-"
  role                    = aws_iam_role.proxy_exec_role.name

  depends_on              = [ aws_iam_role.proxy_exec_role ]
}

