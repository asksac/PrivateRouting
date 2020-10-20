resource "aws_lb" "nlb" {
  name                    = "${var.app_shortcode}-proxy-nlb-${substr(uuid(),0, 3)}"
  internal                = true
  load_balancer_type      = "network"

  subnets                 = var.subnet_ids
  
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }

  tags                    = var.common_tags
}

resource "aws_lb_listener" "nlb_listeners" {
  for_each                = var.proxy_config.port_mappings

  load_balancer_arn       = aws_lb.nlb.arn
  port                    = each.value.nlb_port # inbound port of NLB
  protocol                = "TCP"

  default_action {
    type                  = "forward"
    target_group_arn      = aws_lb_target_group.nlb_tgs[each.key].arn
  }
}

resource "aws_lb_target_group" "nlb_tgs" {
  for_each                = var.proxy_config.port_mappings

  name                    = "${var.app_shortcode}-proxysvr-nlb-tg-${substr(uuid(),0, 3)}"
  port                    = each.value.proxy_port # outbound port of NLB / inbound of targets
  protocol                = "TCP"
  target_type             = "instance"
  vpc_id                  = var.vpc_id

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}

/*
resource "aws_lb_target_group_attachment" "nlb_tg_targets" {
  for_each                = var.proxy_config.port_mappings

  target_group_arn        = aws_lb_target_group.nlb_tgs[each.key].arn
  target_id               = aws_instance.proxy.private_ip
}
*/

resource "aws_route53_record" "nlb_dns" {
  zone_id                 = var.dns_zone_id
  name                    = "proxy-ec2-nlb"
  type                    = "A"

  alias {
    name                  = aws_lb.nlb.dns_name
    zone_id               = aws_lb.nlb.zone_id
    evaluate_target_health= true
  }
}
