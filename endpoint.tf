resource "aws_security_group" "endpoint_sg" {
  name              = "endpoint_sg"
  vpc_id            = aws_vpc.vpc1.id

  dynamic "ingress" {
    for_each        = local.proxy_config.port_mappings
    content {
      cidr_blocks   = [var.vpc1_cidr]
      from_port     = ingress.value.nlb_port
      to_port       = ingress.value.nlb_port
      protocol      = "tcp"
    }
  }

  egress {
    from_port     = 0
    to_port       = 0
    protocol      = "-1"
    cidr_blocks   = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_endpoint_service" "vpces_nlb" {
  acceptance_required         = false
  network_load_balancer_arns  = [ module.proxy.nlb_arn ]
  tags                        = merge(local.common_tags, map("Name", "${var.app_shortcode}_nlb_endpointsvc"))

  depends_on                  = [ module.proxy ]
}

resource "aws_vpc_endpoint" "vpce" {
  vpc_id                      = aws_vpc.vpc1.id
  subnet_ids                  = [ aws_subnet.vpc1_subnet_priv1.id ]
  service_name                = aws_vpc_endpoint_service.vpces_nlb.service_name
  vpc_endpoint_type           = "Interface"
  security_group_ids          = [aws_security_group.endpoint_sg.id]
  tags                        = merge(local.common_tags, map("Name", "${var.app_shortcode}_nlb_endpoint"))

  depends_on                  = [ aws_vpc_endpoint_service.vpces_nlb ]
}
