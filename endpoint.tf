resource "aws_security_group" "endpoint_sg" {
  name            = "endpoint_sg"
  vpc_id          = aws_vpc.vpc1.id
  ingress {
    cidr_blocks   = [var.vpc1_cidr]
    from_port     = var.nlb_listen_ssh_port
    to_port       = var.nlb_listen_ssh_port
    protocol      = "tcp"
  }
  ingress {
    cidr_blocks   = [var.vpc1_cidr]
    from_port     = var.nlb_listen_http_port
    to_port       = var.nlb_listen_http_port
    protocol      = "tcp"
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
  network_load_balancer_arns  = [aws_lb.nlb.arn]
  tags                        = merge(local.common_tags, map("Name", "${var.app_shortcode}_nlb_endpointsvc"))
}

resource "aws_vpc_endpoint" "vpce" {
  vpc_id                      = aws_vpc.vpc1.id
  service_name                = aws_vpc_endpoint_service.vpces_nlb.service_name
  vpc_endpoint_type           = "Interface"
  security_group_ids          = [aws_security_group.endpoint_sg.id]
  tags                        = merge(local.common_tags, map("Name", "${var.app_shortcode}_nlb_endpoint"))
}

output "vpce_dns" {
  value   = aws_vpc_endpoint.vpce.dns_entry 
}