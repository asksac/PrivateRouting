locals {
  # convert list into map keyed on name, as for_each requires map type
  # ignore any list objects where name contains non-alpha-numeric-hyphen chars
  port_mappings_map   = {
    for pm in var.proxy_config.port_mappings: 
    pm.name => pm
    if can(regex("^[0-9A-Za-z-]+$", pm.name)) 
  }

  proxy_userdata          = templatefile("${path.module}/proxy_userdata.tpl", {
    aws_region            = var.aws_region
    port_mappings         = local.port_mappings_map
    ecr_docker_dns        = "${var.ecr_registry_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
    ecr_image_uri         = var.ecr_image_uri
    log_group_name        = aws_cloudwatch_log_group.ec2_proxy_log_group.name
  })
}
