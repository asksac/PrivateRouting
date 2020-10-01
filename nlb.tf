resource "aws_lb" "nlb" {
  name                    = "vpc2-nlb"
  internal                = true
  load_balancer_type      = "network"

  subnet_mapping {
    subnet_id             = aws_subnet.vpc2_subnet_priv1.id
    #private_ipv4_address  = var.vpc2_subnet_nlb_priv_ip
  }

  tags                    = local.common_tags
}

resource "aws_lb_listener" "nlb_listener" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = var.nlb_listen_port # inbound port of NLB
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_tg.arn
  }
}

resource "aws_lb_target_group" "nlb_tg" {
  name        = "nlb-target-group"
  port        = var.proxy_listen_port # outbound port of NLB / inbound of targets
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = aws_vpc.vpc2.id
}

resource "aws_lb_target_group_attachment" "nlb_nat" {
  target_group_arn  = aws_lb_target_group.nlb_tg.arn
  target_id         = aws_instance.proxy.id
  depends_on        = [aws_instance.proxy]
}

