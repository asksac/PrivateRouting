locals {
  proxy_userdata        = templatefile("template/proxy_userdata.tpl", {
    port_mappings       = local.port_mappings_updated
  })
}

resource "aws_lb" "nlb_ec2" {
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

resource "aws_lb_listener" "nlb_ec2_listener_http" {
  load_balancer_arn   = aws_lb.nlb_ec2.arn
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

resource "aws_security_group" "proxy_sg" {
  name            = "proxy_sg"
  vpc_id          = aws_vpc.vpc2.id

  ingress {
    cidr_blocks   = [var.vpc3_cidr]
    from_port     = 22
    to_port       = 22
    protocol      = "tcp"
  }

  dynamic "ingress" {
    for_each        = local.port_mappings_updated
    content {
      cidr_blocks   = [var.vpc1_cidr, var.vpc2_cidr, var.vpc3_cidr]
      from_port     = ingress.value.proxy_port
      to_port       = ingress.value.proxy_port
      protocol      = "tcp"
    }
  }

  egress {
    from_port     = 0
    to_port       = 0
    protocol      = "-1"
    cidr_blocks   = ["0.0.0.0/0"]
  }
  tags            = local.common_tags
}

resource "aws_iam_instance_profile" "proxy_instance_profile" {
  name                  = "${var.app_shortcode}-proxy-instance-profile"
  role                  = aws_iam_role.proxy_exec_role.name
}

resource "aws_instance" "proxy" {
  ami                     = data.aws_ami.ec2_ami.id
  instance_type           = "c5.large"
  subnet_id               = aws_subnet.vpc2_subnet_priv1.id
  vpc_security_group_ids  = [aws_security_group.proxy_sg.id]
  key_name                = var.ec2_ssh_keypair_name
  user_data               = local.proxy_userdata
  source_dest_check       = false
  iam_instance_profile    = aws_iam_instance_profile.proxy_instance_profile.name

  tags                    = merge(local.common_tags, map("Name", "${var.app_shortcode}_proxy"))
}

output "proxysvr_dns" {
  value = aws_instance.proxy.private_dns
}

output "nlb_dns" {
  value   = aws_lb.nlb.dns_name 
}
