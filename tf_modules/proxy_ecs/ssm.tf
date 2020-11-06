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
