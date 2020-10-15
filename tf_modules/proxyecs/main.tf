locals {
  haproxy_config        = templatefile("${path.module}/haproxy.cfg.tpl", {
    port_mappings       = var.proxy_config.port_mappings
  })

  port_mappings_task_def_json = jsonencode([
    for pm in var.proxy_config.port_mappings: { 
      containerPort = pm.proxy_port, 
      hostPort = pm.proxy_port
    }
  ])
}

resource "aws_cloudwatch_log_group" "ecs_proxy_log_group" {
  name                  = "${var.app_name}/${var.proxy_config.service_name}"
  tags                  = var.common_tags
}

resource "aws_ssm_parameter" "haproxy_config" {
  description           = "Contents of haproxy.cfg file"
  type                  = "String"
  name                  = "/${var.app_name}/HAPROXY_CONFIG"
  value                 = local.haproxy_config
  overwrite             = true
  tags                  = merge(var.common_tags, map("CFG_HASH", md5(local.haproxy_config)))
}
