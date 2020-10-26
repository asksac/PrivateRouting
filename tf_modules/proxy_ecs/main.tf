locals {
  haproxy_config        = templatefile("${path.module}/haproxy.cfg.tpl", {
    port_mappings       = var.proxy_config.port_mappings
  })

  port_mappings_task_def_json = jsonencode([
    for pm in var.proxy_config.port_mappings: { 
      containerPort = pm.proxy_port, 
      hostPort = pm.proxy_port,
      protocol = "tcp"
    }
  ])
}

resource "aws_cloudwatch_log_group" "ecs_proxy_log_group" {
  name                  = "${var.app_name}/${var.proxy_config.service_name}"
  tags                  = var.common_tags
}

resource "aws_ssm_parameter" "haproxy_config" {
  name                  = "/${var.app_name}/HAPROXY_CONFIG"
  type                  = "String"
  description           = "Contents of haproxy.cfg file"
  value                 = local.haproxy_config
  # standard tier supports upto 4kb and advanced tier supports upto 8kb
  tier                  = length(local.haproxy_config) > 4096 ? "Advanced" : "Standard" 
  overwrite             = true
  tags                  = var.common_tags
}
