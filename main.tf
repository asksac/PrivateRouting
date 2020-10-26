provider "aws" {
  profile = var.aws_profile
  region = var.aws_region
}

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Project     = "PrivateRouting"
    Application = "AWS-OnPrem-Private-Routing"
    Environment = "dev"
  }

  proxy_config = {
    service_name = "myproxy"
    port_mappings = {
      websvr-ssh = {
        description = "ssh connnection to websvr"
        backend_host = module.test_websvr.alias_dns
        backend_port = 22
        nlb_port = 7022
        proxy_port = 7022
      }

      websvr-http = {
        description = "http connnection to websvr"
        backend_host = module.test_websvr.alias_dns
        backend_port = 80
        nlb_port = 7080
        proxy_port = 7080
      }

      websvr-https = {
        description = "https connnection to websvr"
        backend_host = module.test_websvr.alias_dns
        backend_port = 443
        nlb_port = 7443
        proxy_port = 7443
      }

      nginx1-http = {
        description = "http connnection to nginx"
        backend_host = module.test_websvr.alias_dns
        backend_port = 8080
        nlb_port = 9080
        proxy_port = 9080
      }

      nginx1-https = {
        description = "https connnection to nginx"
        backend_host = module.test_websvr.alias_dns
        backend_port = 8443
        nlb_port = 9443
        proxy_port = 9443
      }
    }
  }
}

# using custom ami created using packer
data "aws_ami" "ec2_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name      = "name"
    values    = ["${var.app_name}-*"]
  }

}

module "test_websvr" {
  source = "./tf_modules/test_websvr"

  aws_region            = var.aws_region
  app_shortcode         = var.app_shortcode

  ec2_ami_id            = data.aws_ami.ec2_ami.id
  ec2_instance_type     = "c5.large"
  ec2_ssh_keypair_name  = var.ec2_ssh_keypair_name

  vpc_id                = aws_vpc.vpc3.id
  subnet_id             = aws_subnet.vpc3_subnet_pub1.id
  dns_zone_id           = aws_route53_zone.dns_zone.zone_id
  vpc_route_table_id    = aws_vpc.vpc1.main_route_table_id
  source_cidr_blocks    = [ var.vpc1_cidr, var.vpc2_cidr ]
  ssh_source_cidr_blocks  = ["0.0.0.0/0"]

  websvr_listen_ports   = {
    server_http_ports     = [ 80 ]
    server_https_ports    = [ 443 ]
    server_ssh_ports      = [ 22 ]
    nginx_http_ports      = [ 8080, 8081 ]
    nginx_https_ports     = [ 8443, 8444 ]
  }

  common_tags           = local.common_tags
}

module "test_client" {
  source = "./tf_modules/test_client"

  aws_region            = var.aws_region
  app_shortcode         = var.app_shortcode

  ec2_ami_id            = data.aws_ami.ec2_ami.id
  ec2_instance_type     = "m5.large"
  ec2_ssh_keypair_name  = var.ec2_ssh_keypair_name

  vpc_id                = aws_vpc.vpc1.id
  subnet_id             = aws_subnet.vpc1_subnet_priv1.id
  dns_zone_id           = aws_route53_zone.dns_zone.zone_id  
  vpc_route_table_id    = aws_vpc.vpc1.main_route_table_id
  source_cidr_blocks    = [ var.vpc2_cidr, var.vpc3_cidr ]

  common_tags           = local.common_tags
}

#
# Output
#

output "webserver_config" {
  value = {
    "private_dns"         = module.test_websvr.private_dns
    "public_dns"          = module.test_websvr.public_dns
    "alias_dns"           = module.test_websvr.alias_dns
  }
}

output "client_config" {
  value = {
    "private_dns"         = module.test_client.private_dns
    "public_dns"          = module.test_client.public_dns
    "alias_dns"           = module.test_client.alias_dns
  }
}
