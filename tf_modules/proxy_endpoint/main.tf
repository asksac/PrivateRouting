/**
 * # Module: proxy_endpoint
 *
 * This module assists in creating a VPC endpoint associated with a specified Endpoint Service, such as a Network Load Balancer. 
 *
 * ### Usage: 
 * 
 * ```hcl
 * module "ecs_proxy_endpoint" {
 *   source                    = "./tf_modules/proxy_endpoint"
 * 
 *   app_shortcode             = "prt"
 *
 *   endpoint_service_name     = module.proxy_ecs.endpoint_service_name
 *   vpc_id                    = aws_vpc.my_non_routable_vpc.id
 *   subnet_ids                = [ aws_subnet.my_non_routable_vpc_subnet1.id ]
 *   source_cidr_blocks        = [ aws_vpc.my_non_routable_vpc.cidr_block ]
 * 
 *   dns_zone_id               = aws_route53_zone.dns_zone.zone_id  
 *   dns_custom_hostname       = "proxy-ecs-endpoint"
 *
 *   proxy_config              = {
 *     service_name            = "myproxy"
 *     port_mappings           = [
 *       {
 *         name                = "api_svc"
 *         description         = "Connection to backend API service"
 *         backend_host        = "api.corp.mydomain.net"
 *         backend_port        = 443
 *         nlb_port            = 8443
 *         proxy_port          = 8443
 *       }
 *     ]
 *   }
 *
 *   common_tags               = local.common_tags
 * }
 * ```
 */

terraform {
  required_version    = ">= 0.12"
  required_providers {
    aws               = ">= 3.11.0"
  }
}

locals {
  # convert list into map keyed on name, as for_each requires map type
  # ignore any list objects where name contains non-alpha-numeric-hyphen chars
  port_mappings_map   = {
    for pm in var.proxy_config.port_mappings: 
    pm.name => pm
    if can(regex("^[0-9A-Za-z-]+$", pm.name)) 
  }
}

resource "aws_vpc_endpoint" "vpce" {
  service_name            = var.endpoint_service_name
  vpc_id                  = var.vpc_id
  subnet_ids              = var.subnet_ids

  auto_accept             = true
  vpc_endpoint_type       = "Interface"

  security_group_ids      = [ aws_security_group.endpoint_sg.id ]
  tags                    = merge(var.common_tags, map("Name", "${var.app_shortcode}-endpoint-${var.dns_custom_hostname}"))
}

resource "aws_route53_record" "vpce_alias_dns" {
  zone_id                 = var.dns_zone_id
  name                    = var.dns_custom_hostname
  type                    = "A"

  alias {
    name                  = aws_vpc_endpoint.vpce.dns_entry[0]["dns_name"]
    zone_id               = aws_vpc_endpoint.vpce.dns_entry[0]["hosted_zone_id"]
    evaluate_target_health  = true
  }
}
