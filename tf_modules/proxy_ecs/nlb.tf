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
  target_type             = "ip" # ECS requires target type as ip
  vpc_id                  = var.vpc_id

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }

  deregistration_delay    = 120 # default is 300s

  health_check {
    enabled               = true
    healthy_threshold     = 2 # default is 3
    unhealthy_threshold   = 2 # default is 3
    interval              = 10 # default is 30
    #matcher               = "" # cannot be changed for nlb
    #path                  = "" # cannot be changed for nlb
    #timeout               = 10 # cannot be changed for nlb
    port                  = "traffic-port"
    protocol              = "TCP"
  }
}
