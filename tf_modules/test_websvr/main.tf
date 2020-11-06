locals {
  websvr_user_data        = templatefile("${path.module}/websvr_userdata.tpl", {
    websvr_listen_ports   = var.websvr_listen_ports
  })
}

resource "aws_security_group" "websvr_sg" {
  name_prefix             = "${var.app_shortcode}-websvr-sg"
  vpc_id                  = var.vpc_id

  ingress {
    cidr_blocks           = var.ssh_source_cidr_blocks
    from_port             = 22
    to_port               = 22
    protocol              = "tcp"
  }

  dynamic "ingress" {
    for_each              = flatten(values(var.websvr_listen_ports))
    content {
      cidr_blocks         = var.source_cidr_blocks 
      from_port           = ingress.value
      to_port             = ingress.value
      protocol            = "tcp"
    }
  }

  # Terraform removes the default rule
  egress {
    from_port             = 0
    to_port               = 0
    protocol              = "-1"
    cidr_blocks           = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "websvr" {
  ami                     = var.ec2_ami_id
  instance_type           = var.ec2_instance_type
  key_name                = var.ec2_ssh_keypair_name
  user_data               = local.websvr_user_data

  subnet_id               = var.subnet_id
  vpc_security_group_ids  = [ aws_security_group.websvr_sg.id ]
  source_dest_check       = false

  tags                    = merge(var.common_tags, map("Name", "${var.app_shortcode}-websvr"))
}

resource "aws_route53_record" "alias_dns" {
  zone_id                 = var.dns_zone_id
  name                    = var.dns_custom_hostname
  type                    = "A"
  ttl                     = "60"
  records                 = [ aws_instance.websvr.private_ip ]
}