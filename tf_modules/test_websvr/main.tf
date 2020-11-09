/**
 * # Module: test_websvr
 *
 * This module can be used to create a webserver instance to assist in testing  
 * of HAProxy cluster (refer to diagram to see where websvr is located). Also, refer to
 * websvr_userdata.tpl file to view the EC2 instance user data script, in order to 
 * understand how Python based and Nginx webserver listeners are deployed. 
 * 
 * ### Usage: 
 * 
 * ```hcl
 * module "test_websvr" {
 *   source = "./tf_modules/test_websvr"
 * 
 *   aws_region            = "us-east-1"
 *   app_shortcode         = "prt"
 * 
 *   ec2_ami_id            = data.aws_ami.ec2_ami.id
 *   ec2_instance_type     = "m5.large"
 *   ec2_ssh_keypair_name  = "my_ssh_keypair"
 * 
 *   vpc_id                = aws_vpc.my_backend_vpc.id
 *   subnet_id             = aws_subnet.my_backend_vpc_subnet1.id
 *   s3_endpoint_enabled   = true
 *   vpc_route_table_id    = aws_vpc.my_backend_vpc.main_route_table_id
 *   source_cidr_blocks    = [ aws_vpc.my_non_routable_vpc.cidr_block ]
 *   ssh_source_cidr_blocks= ["0.0.0.0/0"]
 * 
 *   dns_zone_id           = aws_route53_zone.dns_zone.zone_id  
 *   dns_custom_hostname   = "websvr"
 *
 *   websvr_listen_ports   = {
 *     server_http_ports   = [ 8080, 8081 ] # runs python webservers in http mode
 *     server_https_ports  = [ 8443, 8444 ] # runs python webservers in https mode
 *     server_ssh_ports    = [ 22 ] # currently only sshd at port 22 is supported
 *     nginx_http_ports    = [ 9090, 9091 ] # runs nginx listeners in http mode
 *     nginx_https_ports   = [ 9443, 9444 ] # runs nginx listeners in https mode
 *   }
 *
 *   common_tags           = local.common_tags
 * }
 * ```
 */

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

# create s3 endpoint to allow access to amzn yum repo
resource "aws_vpc_endpoint" "websvr_vpce_s3" {
  count                   = var.s3_endpoint_enabled ? 1 : 0
  
  service_name            = "com.amazonaws.${var.aws_region}.s3"

  vpc_id                  = var.vpc_id
  route_table_ids         = [ var.vpc_route_table_id ]

  auto_accept             = true
  vpc_endpoint_type       = "Gateway"

  tags                    = merge(var.common_tags, map("Name", "${var.app_shortcode}-s3-endpoint"))
}
