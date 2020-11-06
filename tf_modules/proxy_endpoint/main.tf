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
  vpc_id                  = var.vpc.id
  subnet_ids              = var.subnet_ids

  auto_accept             = true
  vpc_endpoint_type       = "Interface"

  security_group_ids      = [ aws_security_group.endpoint_sg.id ]
  tags                    = merge(var.common_tags, map("Name", "${var.endpoint_name}-endpoint"))
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
