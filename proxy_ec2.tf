#
# Proxy running on EC2 instance (supports single instance only for now)
# HAProxy on EC2 allows for better access and troubleshooting network
# and other configuration issues 

module "proxy_ec2" {
  source = "./tf_modules/proxy_ec2"

  aws_region              = var.aws_region
  app_name                = var.app_name
  app_shortcode           = var.app_shortcode

  vpc_id                  = aws_vpc.vpc2.id
  #subnet_ids              = [ aws_subnet.vpc2_subnet_priv1.id, aws_subnet.vpc2_subnet_priv2.id ]
  subnet_ids              = [ aws_subnet.vpc2_subnet_priv1.id ]
  dns_zone_id             = aws_route53_zone.dns_zone.zone_id  
  source_cidr_blocks      = [ var.vpc1_cidr, var.vpc2_cidr, var.vpc3_cidr ]

  ec2_ami_id              = data.aws_ami.ec2_ami.id
  ec2_ssh_keypair_name    = var.ec2_ssh_keypair_name

  ecr_registry_id         = aws_ecr_repository.registry.registry_id
  ecr_image_uri           = "${aws_ecr_repository.registry.repository_url}:1.0"
  proxy_config            = local.ec2_proxy_config

  common_tags             = local.common_tags
}

module "proxy_ec2_endpoint" {
  source                  = "./tf_modules/proxy_endpoint"

  app_shortcode           = var.app_shortcode
  endpoint_name           = "proxy-ec2-vpce"

  vpc                     = aws_vpc.vpc1
  #subnet_ids              = [ aws_subnet.vpc1_subnet_priv1.id, aws_subnet.vpc1_subnet_priv2.id ] 
  subnet_ids              = [ aws_subnet.vpc1_subnet_priv1.id ] 
  dns_zone_id             = aws_route53_zone.dns_zone.zone_id  

  proxy_config            = local.ec2_proxy_config
  endpoint_service_name   = module.proxy_ec2.endpoint_service_name

  common_tags             = local.common_tags
}

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

#
# Output
#

output "proxy_ec2" {
  value = {
    "nlb_dns"             = module.proxy_ec2.nlb_dns
    "endpoint_dns"        = module.proxy_ec2_endpoint.endpoint_dns 
    "endpoint_alias_dns"  = module.proxy_ec2_endpoint.alias_dns
  }
}