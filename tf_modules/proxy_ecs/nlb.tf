resource "aws_lb" "nlb" {
  name                    = "${var.app_shortcode}-proxyecs-nlb-${substr(uuid(),0, 3)}"
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

  name                    = "${var.app_shortcode}-proxyecs-nlb-tg-${each.key}"
  port                    = each.value.proxy_port # outbound port of NLB / inbound of targets
  protocol                = "TCP"  
  target_type             = "ip" # ECS requires target type as ip
  vpc_id                  = var.vpc_id

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }

  deregistration_delay    = 180 # default is 300s

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

resource "aws_route53_record" "nlb_dns" {
  zone_id                 = var.dns_zone_id
  name                    = "proxy-ecs-nlb"
  type                    = "A"

  alias {
    name                  = aws_lb.nlb.dns_name
    zone_id               = aws_lb.nlb.zone_id
    evaluate_target_health= true
  }
}
