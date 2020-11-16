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
  subnet_ids              = [ aws_subnet.vpc2_subnet_priv1.id, aws_subnet.vpc2_subnet_priv2.id ]
  #subnet_ids              = [ aws_subnet.vpc2_subnet_priv1.id ]
  dns_zone_id             = aws_route53_zone.dns_zone.zone_id  
  dns_custom_hostname     = "proxy-ec2-nlb"
  source_cidr_blocks      = [ var.vpc2_cidr ]

  ec2_ami_id              = data.aws_ami.ec2_ami.id
  ec2_ssh_enabled         = var.ec2_ssh_enabled
  ec2_ssh_keypair_name    = var.ec2_ssh_keypair_name
  ssh_source_cidr_blocks  = [ var.vpc3_cidr ]

  min_cluster_size        = 2

  ecr_registry_id         = aws_ecr_repository.registry.registry_id
  ecr_image_uri           = "${aws_ecr_repository.registry.repository_url}:1.0"
  proxy_config            = local.ec2_proxy_config

  common_tags             = local.common_tags
}

module "proxy_ec2_endpoint" {
  source                  = "./tf_modules/proxy_endpoint"

  app_shortcode           = var.app_shortcode
  endpoint_service_name   = module.proxy_ec2.endpoint_service_name

  vpc_id                  = aws_vpc.vpc1.id
  subnet_ids              = [ aws_subnet.vpc1_subnet_priv1.id, aws_subnet.vpc1_subnet_priv2.id ] 
  #subnet_ids              = [ aws_subnet.vpc1_subnet_priv1.id ] 
  dns_zone_id             = aws_route53_zone.dns_zone.zone_id  
  dns_custom_hostname     = "proxy-ec2-vpce"
  source_cidr_blocks      = [ var.vpc1_cidr ]

  proxy_config            = local.ec2_proxy_config
  
  #depends_on              = [ module.proxy_ec2 ]
  common_tags             = local.common_tags
}

#
# Output
#
output "proxy_ec2" {
  value                   = {
    "nlb_dns"             = module.proxy_ec2.nlb_dns
    "endpoint_dns"        = module.proxy_ec2_endpoint.endpoint_dns 
    "endpoint_alias_dns"  = module.proxy_ec2_endpoint.alias_dns
  }

  description             = "DNS values of NLB and Endpoint associated with HAProxy on EC2 cluster"
}