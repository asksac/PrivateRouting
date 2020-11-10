/**
 * # Module: test_client
 *
 * This module can be used to create a client ec2 instance to assist in testing of HAProxy cluster (refer to diagram to see where client instance is located). By default, the client instance has `httpd-tools` package installed. This provides access to utilities such as Apache Bench (for load testing). 
 * 
 * ### Usage: 
 * 
 * ```hcl
 * module "test_client" {
 *   source = "./tf_modules/test_client"
 * 
 *   aws_region            = "us-east-1"
 *   app_shortcode         = "prt"
 * 
 *   ec2_ami_id            = data.aws_ami.ec2_ami.id
 *   ec2_instance_type     = "m5.large"
 *   ec2_ssh_keypair_name  = "my_ssh_keypair"
 * 
 *   vpc_id                = aws_vpc.my_non_routable_vpc.id
 *   subnet_id             = aws_subnet.my_non_routable_vpc_subnet1.id
 *   s3_endpoint_enabled   = true
 *   vpc_route_table_id    = aws_vpc.my_non_routable_vpc.main_route_table_id
 *   ssh_source_cidr_blocks= [ aws_vpc.my_bastion_vpc.cidr_block ]
 * 
 *   dns_zone_id           = aws_route53_zone.dns_zone.zone_id  
 *   dns_custom_hostname   = "client"

 *   common_tags           = local.common_tags
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
  client_user_data        = templatefile("${path.module}/client_userdata.tpl", {
  })
}

resource "aws_security_group" "client_sg" {
  name_prefix             = "${var.app_shortcode}-client-sg"
  vpc_id                  = var.vpc_id

  ingress {
    cidr_blocks           = var.ssh_source_cidr_blocks
    from_port             = 22
    to_port               = 22
    protocol              = "tcp"
  }

  # terraform removes the default egress rule, so lets add it back
  egress {
    from_port             = 0
    to_port               = 0
    protocol              = "-1"
    cidr_blocks           = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "client_ec2" {
  ami                     = var.ec2_ami_id
  instance_type           = var.ec2_instance_type
  key_name                = var.ec2_ssh_keypair_name
  user_data               = local.client_user_data

  subnet_id               = var.subnet_id
  vpc_security_group_ids  = [ aws_security_group.client_sg.id ]
  source_dest_check       = true

  tags                    = merge(var.common_tags, map("Name", "${var.app_shortcode}-client"))
}

resource "aws_route53_record" "alias_dns" {
  zone_id                 = var.dns_zone_id
  name                    = var.dns_custom_hostname 
  type                    = "A"
  ttl                     = "60"
  records                 = [ aws_instance.client_ec2.private_ip ]
}

# create s3 endpoint to allow access to amzn yum repo
resource "aws_vpc_endpoint" "client_vpce_s3" {
  count                   = var.s3_endpoint_enabled ? 1 : 0
  
  service_name            = "com.amazonaws.${var.aws_region}.s3"

  vpc_id                  = var.vpc_id
  route_table_ids         = [ var.vpc_route_table_id ]

  auto_accept             = true
  vpc_endpoint_type       = "Gateway"

  tags                    = merge(var.common_tags, map("Name", "${var.app_shortcode}-s3-endpoint"))
}
