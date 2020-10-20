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

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
    #matcher             = "" # cannot be changed for nlb
    #path                = "" # cannot be changed for nlb
    #timeout             = 10 # cannot be changed for nlb
    port                = "traffic-port"
    protocol            = "TCP"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}

resource "aws_vpc_endpoint_service" "vpces_nlb" {
  acceptance_required         = false
  network_load_balancer_arns  = [ aws_lb.nlb.arn ]
  tags                        = merge(var.common_tags, map("Name", "${var.app_shortcode}_nlb_endpointsvc"))

  lifecycle {
    create_before_destroy     = true
  }
}