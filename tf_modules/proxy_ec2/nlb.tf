resource "aws_lb" "nlb" {
  name                    = "${var.app_shortcode}-${var.proxy_config.service_name}-nlb-${substr(uuid(),0, 3)}"
  internal                = true
  load_balancer_type      = "network"

  subnets                 = var.subnet_ids
  enable_cross_zone_load_balancing  = true
  
  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }

  tags                    = var.common_tags
}

resource "aws_lb_listener" "nlb_listeners" {
  for_each                = local.port_mappings_map

  load_balancer_arn       = aws_lb.nlb.arn
  port                    = each.value.nlb_port # inbound port of NLB
  protocol                = "TCP"

  default_action {
    type                  = "forward"
    target_group_arn      = aws_lb_target_group.nlb_tgs[each.key].arn
  }
}

resource "aws_lb_target_group" "nlb_tgs" {
  for_each                = local.port_mappings_map

  name                    = "${var.proxy_config.service_name}-tg-${each.key}"
  port                    = each.value.proxy_port # outbound port of NLB / inbound of targets
  protocol                = "TCP"
  target_type             = "instance" # Auto Scaling requires target type to be instance
  vpc_id                  = var.vpc_id
}

/*
resource "aws_lb_target_group_attachment" "nlb_tg_targets" {
  for_each                = var.proxy_config.port_mappings

  target_group_arn        = aws_lb_target_group.nlb_tgs[each.key].arn
  target_id               = aws_instance.proxy.private_ip
}
*/
