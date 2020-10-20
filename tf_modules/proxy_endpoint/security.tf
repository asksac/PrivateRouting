resource "aws_security_group" "endpoint_sg" {
  name_prefix             = "${var.endpoint_name}-endpoint-sg"
  vpc_id                  = var.vpc.id

  dynamic "ingress" {
    for_each              = var.proxy_config.port_mappings
    content {
      cidr_blocks         = [ var.vpc.cidr_block ]
      from_port           = ingress.value.nlb_port
      to_port             = ingress.value.nlb_port
      protocol            = "tcp"
    }
  }

  egress {
    from_port             = 0
    to_port               = 0
    protocol              = "-1"
    cidr_blocks           = ["0.0.0.0/0"]
  }
}