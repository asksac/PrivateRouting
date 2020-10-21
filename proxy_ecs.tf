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
  source_cidr_blocks      = [ var.vpc1_cidr, var.vpc2_cidr, var.vpc3_cidr ]

  image_uri               = "${aws_ecr_repository.registry.repository_url}:1.0"
  proxy_config            = local.proxy_config

  common_tags             = local.common_tags
}

module "proxy_ecs_endpoint" {
  source                  = "./tf_modules/proxy_endpoint"

  app_shortcode           = var.app_shortcode
  endpoint_name           = "proxy-ecs-vpce"

  vpc                     = aws_vpc.vpc1
  #subnet_ids              = [ aws_subnet.vpc1_subnet_priv1.id, aws_subnet.vpc1_subnet_priv2.id ] 
  subnet_ids              = [ aws_subnet.vpc1_subnet_priv1.id ] 
  dns_zone_id             = aws_route53_zone.dns_zone.zone_id  

  proxy_config            = local.proxy_config
  endpoint_service_name   = module.proxy_ecs.endpoint_service_name

  common_tags             = local.common_tags
}

output "proxy_ecs" {
  value = {
    "nlb_dns"             = module.proxy_ecs.nlb_dns
    "endpoint_dns"        = module.proxy_ecs_endpoint.endpoint_dns 
    "endpoint_alias_dns"  = module.proxy_ecs_endpoint.alias_dns
  }
}

/*
output "PECS_vpc_endpoint_dns" {
  value                   = module.proxy_ecs_endpoint.endpoint_dns 
}

output "PECS_nlb_dns" {
  value                   = module.proxy.nlb_dns
}
*/