#
# Proxy running on ECS Fargate cluster
#

module "proxy_ecs" {
  source = "./tf_modules/proxy_ecs"

  aws_region              = var.aws_region
  app_name                = var.app_name
  app_shortcode           = var.app_shortcode

  vpc_id                  = aws_vpc.vpc2.id
  #subnet_ids              = [ aws_subnet.vpc2_subnet_priv1.id, aws_subnet.vpc2_subnet_priv2.id ]
  subnet_ids              = [ aws_subnet.vpc2_subnet_priv1.id ]
  dns_zone_id             = aws_route53_zone.dns_zone.zone_id  
  dns_custom_hostname     = "proxy-ecs-nlb"
  source_cidr_blocks      = [ var.vpc2_cidr ]

  ecr_image_uri           = "${aws_ecr_repository.registry.repository_url}:1.0"
  proxy_config            = local.ecs_proxy_config

  common_tags             = local.common_tags
}

module "proxy_ecs_endpoint" {
  source                  = "./tf_modules/proxy_endpoint"

  app_shortcode           = var.app_shortcode
  endpoint_service_name   = module.proxy_ecs.endpoint_service_name

  vpc_id                  = aws_vpc.vpc1.id
  #subnet_ids              = [ aws_subnet.vpc1_subnet_priv1.id, aws_subnet.vpc1_subnet_priv2.id ] 
  subnet_ids              = [ aws_subnet.vpc1_subnet_priv1.id ] 
  dns_zone_id             = aws_route53_zone.dns_zone.zone_id  
  dns_custom_hostname     = "proxy-ecs-vpce"
  source_cidr_blocks      = [ var.vpc1_cidr ]

  proxy_config            = local.ecs_proxy_config

  common_tags             = local.common_tags
}

output "proxy_ecs" {
  value                   = {
    "nlb_dns"             = module.proxy_ecs.nlb_dns
    "endpoint_dns"        = module.proxy_ecs_endpoint.endpoint_dns 
    "endpoint_alias_dns"  = module.proxy_ecs_endpoint.alias_dns
  }

  description             = "DNS values of NLB and Endpoint associated with HAProxy on ECS cluster"
}
