# 
# Creates a test webserver and test client ec2 instances (as shown in the diagram)
# These instances are needed for testing purposes only 
# 
module "test_websvr" {
  source = "./tf_modules/test_websvr"

  aws_region            = var.aws_region
  app_shortcode         = var.app_shortcode

  ec2_ami_id            = data.aws_ami.ec2_ami.id
  ec2_instance_type     = "c5.large"
  ec2_ssh_enabled       = var.ec2_ssh_enabled
  ec2_ssh_keypair_name  = var.ec2_ssh_keypair_name

  vpc_id                = aws_vpc.vpc3.id
  subnet_id             = aws_subnet.vpc3_subnet_pub1.id
  s3_endpoint_enabled   = true # enables amzn yum repo access
  vpc_route_table_id    = aws_vpc.vpc3.main_route_table_id
  source_cidr_blocks    = [ var.vpc2_cidr ]
  ssh_source_cidr_blocks  = ["0.0.0.0/0"]

  dns_zone_id           = aws_route53_zone.dns_zone.zone_id
  dns_custom_hostname   = "websvr"
  websvr_listen_ports   = local.test_websvr_ports

  common_tags           = local.common_tags
}

module "test_client" {
  source = "./tf_modules/test_client"

  aws_region            = var.aws_region
  app_shortcode         = var.app_shortcode

  ec2_ami_id            = data.aws_ami.ec2_ami.id
  ec2_instance_type     = "m5.large"
  ec2_ssh_enabled       = var.ec2_ssh_enabled
  ec2_ssh_keypair_name  = var.ec2_ssh_keypair_name

  vpc_id                = aws_vpc.vpc1.id
  subnet_id             = aws_subnet.vpc1_subnet_priv1.id
  s3_endpoint_enabled   = true # enables amzn yum repo access
  vpc_route_table_id    = aws_vpc.vpc1.main_route_table_id
  ssh_source_cidr_blocks = [ var.vpc2_cidr, var.vpc3_cidr ]

  dns_zone_id           = aws_route53_zone.dns_zone.zone_id  
  dns_custom_hostname   = "client"

  common_tags           = local.common_tags
}

#
# Output
#
output "webserver_details" {
  value                   = {
    "private_dns"         = module.test_websvr.private_dns
    "public_dns"          = module.test_websvr.public_dns
    "alias_dns"           = module.test_websvr.alias_dns
  }

  description             = "DNS values of Test WebServer instance"
}

output "client_details" {
  value                   = {
    "private_dns"         = module.test_client.private_dns
    "public_dns"          = module.test_client.public_dns
    "alias_dns"           = module.test_client.alias_dns
  }

  description             = "DNS values of Test Client instance"
}
