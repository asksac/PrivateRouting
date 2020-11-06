resource "aws_security_group" "endpoint_sg" {
  name_prefix             = "${var.endpoint_name}-endpoint-sg-"
  vpc_id                  = var.vpc.id

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

  cidr_blocks             = [ var.vpc.cidr_block ]
  from_port               = each.value.nlb_port
  to_port                 = each.value.nlb_port
  protocol                = "tcp"
}
