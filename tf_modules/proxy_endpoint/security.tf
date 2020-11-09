resource "aws_security_group" "endpoint_sg" {
  name_prefix             = "${var.app_shortcode}-sg-${var.dns_custom_hostname}-"
  vpc_id                  = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }

  egress {
    from_port             = 0
    to_port               = 0
    protocol              = "-1"
    cidr_blocks           = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "endpoint_sg_rule" {
  for_each                = local.port_mappings_map

  type                    = "ingress"
  security_group_id       = aws_security_group.endpoint_sg.id

  cidr_blocks             = var.source_cidr_blocks
  from_port               = each.value.nlb_port
  to_port                 = each.value.nlb_port
  protocol                = "tcp"
}
