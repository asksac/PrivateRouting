provider "aws" {
  profile = var.aws_profile
  region = var.aws_region
}

locals {
  # Common tags to be assigned to all resources
  common_tags = {
    Project     = "PrivateRouting"
    Application = "AWS-HSBC-Private-Routing"
    Environment = "dev"
  }

  proxy_config = {
    service_name = "myproxy"
    port_mappings = {
      websvr-ssh = {
        description = "ssh connnection to websvr"
        backend_host = aws_instance.websvr.private_dns
        backend_port = 22
        nlb_port = 9022
        proxy_port = 9022
      }

      websvr-http = {
        description = "http connnection to websvr"
        backend_host = aws_instance.websvr.private_dns
        backend_port = 8080
        nlb_port = 9080
        proxy_port = 9080
      }

      websvr-https = {
        description = "https connnection to websvr"
        backend_host = aws_instance.websvr.private_dns
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

/*
#
# Proxy running on EC2 instance (supports single instance only)
#

module "proxy" {
  source = "./tf_modules/proxysvr"

  aws_region            = var.aws_region
  app_name              = var.app_name
  app_shortcode         = var.app_shortcode
  vpc_id                = aws_vpc.vpc2.id
  subnet_id             = aws_subnet.vpc2_subnet_priv1.id
  ec2_ami_id            = data.aws_ami.ec2_ami.id
  source_cidr_blocks    = [ var.vpc1_cidr, var.vpc2_cidr, var.vpc3_cidr ]
  ec2_ssh_keypair_name  = var.ec2_ssh_keypair_name
  proxy_config          = local.proxy_config
  common_tags           = local.common_tags
}

output "A_client_dns" {
  value = aws_instance.client_ec2.private_dns
}

output "B_vpc_endpoint_dns" {
  value   = aws_vpc_endpoint.vpce.dns_entry 
}

output "C_nlb_dns" {
  value = module.proxy.nlb_dns
}

output "D_proxy_dns" {
  value = module.proxy.proxysvr_dns
}

output "E_websvr_private_dns" {
  value = aws_instance.websvr.private_dns
}

output "E_websvr_public_dns" {
  value = aws_instance.websvr.public_dns
}
*/

#
# Proxy running on ECS Fargate cluster
#

module "proxy" {
  source = "./tf_modules/proxyecs"

  aws_region            = var.aws_region
  app_name              = var.app_name
  app_shortcode         = var.app_shortcode
  vpc_id                = aws_vpc.vpc2.id
  subnet_ids             = [ aws_subnet.vpc2_subnet_priv1.id, aws_subnet.vpc2_subnet_priv2.id ]
  source_cidr_blocks    = [ var.vpc1_cidr, var.vpc2_cidr, var.vpc3_cidr ]
  proxy_config          = local.proxy_config
  common_tags           = local.common_tags
}

output "A_client_dns" {
  value = aws_instance.client_ec2.private_dns
}

output "B_vpc_endpoint_dns" {
  value   = aws_vpc_endpoint.vpce.dns_entry 
}

output "C_nlb_dns" {
  value = module.proxy.nlb_dns
}

output "D_websvr_private_dns" {
  value = aws_instance.websvr.private_dns
}

output "D_websvr_public_dns" {
  value = aws_instance.websvr.public_dns
}
