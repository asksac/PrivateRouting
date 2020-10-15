resource "aws_ecr_repository" "registry" {
  name                        = "${var.app_shortcode}-registry"
  image_tag_mutability        = "MUTABLE"

  image_scanning_configuration {
    scan_on_push              = false
  }

  lifecycle {
    prevent_destroy           = true
  }

  tags                        = local.common_tags
}

resource "aws_security_group" "ecr_vpce_sg" {
  name                        = "ecr_vpce_sg"
  vpc_id                      = aws_vpc.vpc2.id

  ingress {
    cidr_blocks               = [ aws_vpc.vpc2.cidr_block ]
    from_port                 = 443
    to_port                   = 443
    protocol                  = "tcp"
  }

  egress {
    from_port     = 0
    to_port       = 0
    protocol      = "-1"
    cidr_blocks   = ["0.0.0.0/0"]
  }

  tags                        = local.common_tags
}

# vpc endpoints to ecr (docker, api and s3) are required for fargate tasks to pull container image
resource "aws_vpc_endpoint" "vpce_ecr_dkr" {
  service_name                = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_id                      = aws_vpc.vpc2.id
  subnet_ids                  = [ aws_subnet.vpc2_subnet_priv2.id, aws_subnet.vpc2_subnet_priv2.id ]
  private_dns_enabled         = true

  auto_accept                 = true
  vpc_endpoint_type           = "Interface"

  security_group_ids          = [ aws_security_group.ecr_vpce_sg.id ]
  tags                        = merge(local.common_tags, map("Name", "${var.app_shortcode}_ecr_dkr_endpoint"))
}

resource "aws_vpc_endpoint" "vpce_ecr_api" {
  service_name                = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_id                      = aws_vpc.vpc2.id
  subnet_ids                  = [ aws_subnet.vpc2_subnet_priv2.id, aws_subnet.vpc2_subnet_priv2.id ]
  private_dns_enabled         = true

  auto_accept                 = true
  vpc_endpoint_type           = "Interface"

  security_group_ids          = [ aws_security_group.ecr_vpce_sg.id ]
  tags                        = merge(local.common_tags, map("Name", "${var.app_shortcode}_ecr_api_endpoint"))
}

resource "aws_vpc_endpoint" "vpce_ecr_s3" {
  service_name                = "com.amazonaws.${var.aws_region}.s3"
  vpc_id                      = aws_vpc.vpc2.id
  route_table_ids             = [ aws_vpc.vpc2.main_route_table_id ]

  auto_accept                 = true
  vpc_endpoint_type           = "Gateway"

  tags                        = merge(local.common_tags, map("Name", "${var.app_shortcode}_s3_endpoint"))
}

# vpc endpoint to cloudwatch logs is required for fargate tasks using awslogs logDriver
# ref: https://docs.aws.amazon.com/AmazonECR/latest/userguide/vpc-endpoints.html#ecr-setting-up-cloudwatch-logs
resource "aws_vpc_endpoint" "vpce_cw_logs" {
  service_name                = "com.amazonaws.${var.aws_region}.logs"
  vpc_id                      = aws_vpc.vpc2.id
  subnet_ids                  = [ aws_subnet.vpc2_subnet_priv2.id, aws_subnet.vpc2_subnet_priv2.id ]
  private_dns_enabled         = true

  auto_accept                 = true
  vpc_endpoint_type           = "Interface"

  security_group_ids          = [ aws_security_group.ecr_vpce_sg.id ]
  tags                        = merge(local.common_tags, map("Name", "${var.app_shortcode}_cw_logs_endpoint"))
}
