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

resource "aws_lb_listener" "nlb_listener_ecs" {
  for_each            = var.proxy_config.port_mappings

  load_balancer_arn   = aws_lb.nlb.arn
  port                = each.value.nlb_port # inbound port of NLB
  protocol            = "TCP"

  default_action {
    type              = "forward"
    target_group_arn  = aws_lb_target_group.nlb_tg_ecs[each.key].arn
  }

  depends_on          = [aws_lb.nlb, aws_lb_target_group.nlb_tg_ecs]
}

resource "aws_lb_target_group" "nlb_tg_ecs" {
  for_each            = var.proxy_config.port_mappings

  name                = "nlb-ecs-tg-${each.key}-${substr(uuid(),0, 3)}"
  port                = each.value.proxy_port # outbound port of NLB / inbound of targets
  protocol            = "TCP"
  # ECS requires target type to be ip
  target_type         = "ip"
  vpc_id              = var.vpc_id

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}
