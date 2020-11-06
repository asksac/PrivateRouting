#
# Addon listener bypassing HAProxy (vpc_endpoint -> nlb -> test_websvr)
#

resource "aws_security_group_rule" "vpce_addon_rule" {
  type                    = "ingress"
  security_group_id       = module.proxy_ec2_endpoint.security_group_id

  cidr_blocks             = [ aws_vpc.vpc1.cidr_block ]
  from_port               = var.addon_nlb_port
  to_port                 = var.addon_nlb_port
  protocol                = "tcp"

  depends_on              = [ module.proxy_ec2_endpoint ]
}

resource "aws_lb_listener" "addon_listeners_to_websvr" {
  load_balancer_arn       = module.proxy_ec2.nlb_arn
  port                    = var.addon_nlb_port # inbound port of NLB
  protocol                = "TCP"

  default_action {
    type                  = "forward"
    target_group_arn      = aws_lb_target_group.addon_nlb_tg_to_websvr.arn
  }

  depends_on              = [ aws_security_group_rule.vpce_addon_rule ]
}

resource "aws_lb_target_group" "addon_nlb_tg_to_websvr" {
  name                    = "${var.app_shortcode}-proxysvr-nlb-tg-addon-${substr(uuid(),0, 3)}"
  port                    = var.addon_websvr_port # outbound port of NLB / inbound of targets
  protocol                = "TCP"
  target_type             = "ip"
  vpc_id                  = aws_vpc.vpc2.id

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [ name ]
  }
}

resource "aws_lb_target_group_attachment" "addon_nlb_tg_target" {
  target_group_arn        = aws_lb_target_group.addon_nlb_tg_to_websvr.arn
  target_id               = module.test_websvr.private_ip 
  availability_zone       = aws_subnet.vpc3_subnet_pub1.availability_zone
}
