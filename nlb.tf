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

# ---------- #
# Listener 1 #

resource "aws_lb_listener" "nlb_listener_http" {
  load_balancer_arn   = aws_lb.nlb.arn
  port                = var.nlb_listen_http_port # inbound port of NLB
  protocol            = "TCP"

  default_action {
    type              = "forward"
    target_group_arn  = aws_lb_target_group.nlb_tg_http.arn
  }

  depends_on          = [aws_lb_target_group.nlb_tg_http]
}

resource "aws_lb_target_group" "nlb_tg_http" {
  name        = "nlb-http-target-group-${substr(uuid(),0, 3)}"
  port        = var.proxy_listen_http_port # outbound port of NLB / inbound of targets
  protocol    = "TCP"
  # ref https://aws.amazon.com/premiumsupport/knowledge-center/target-connection-fails-load-balancer/
  target_type = "ip"
  vpc_id      = aws_vpc.vpc2.id

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}

resource "aws_lb_target_group_attachment" "nlb_tg_http_targets" {
  target_group_arn  = aws_lb_target_group.nlb_tg_http.arn
  target_id         = aws_instance.proxy.private_ip
  depends_on        = [aws_instance.proxy]
}

# ---------- #
# Listener 2 #

resource "aws_lb_listener" "nlb_listener_ssh" {
  load_balancer_arn = aws_lb.nlb.arn
  port              = var.nlb_listen_ssh_port # inbound port of NLB
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_tg_ssh.arn
  }

  depends_on          = [aws_lb_target_group.nlb_tg_ssh]
}

resource "aws_lb_target_group" "nlb_tg_ssh" {
  name        = "nlb-ssh-target-group-${substr(uuid(),0, 3)}"
  port        = var.proxy_listen_ssh_port # outbound port of NLB / inbound of targets
  protocol    = "TCP"
  target_type = "ip" 
  vpc_id      = aws_vpc.vpc2.id

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [name]
  }
}

resource "aws_lb_target_group_attachment" "nlb_tg_ssh_targets" {
  target_group_arn  = aws_lb_target_group.nlb_tg_ssh.arn
  target_id         = aws_instance.proxy.private_ip
  depends_on        = [aws_instance.proxy]
}

output "nlb_dns" {
  value   = aws_lb.nlb.dns_name 
}