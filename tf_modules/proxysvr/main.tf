
locals {
  proxy_userdata        = templatefile("${path.module}/proxy_userdata.tpl", {
    port_mappings       = var.proxy_config.port_mappings
  })
}

resource "aws_instance" "proxy" {
  ami                     = var.ec2_ami_id
  instance_type           = "c5.large"
  subnet_id               = var.subnet_ids[0]
  vpc_security_group_ids  = [aws_security_group.proxy_sg.id]
  key_name                = var.ec2_ssh_keypair_name
  user_data               = local.proxy_userdata
  source_dest_check       = false
  iam_instance_profile    = aws_iam_instance_profile.proxy_instance_profile.name

  tags                    = merge(var.common_tags, map("Name", "${var.app_shortcode}_proxysvr"))
}
