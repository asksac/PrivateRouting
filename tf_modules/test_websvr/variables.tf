variable "aws_region" {
  default                 = "us-east-1"
}

variable "app_shortcode" {}

variable "vpc_id" {}

variable "subnet_id" {}

variable "dns_zone_id" {}

variable "dns_custom_hostname" {
  description             = "Specify a custom Route53 record name to map to this websvr instance"
}

variable "ec2_ami_id" {}

variable "ec2_instance_type" {
  default                 = "m5.large"
}

variable "ec2_ssh_keypair_name" {}

variable "vpc_route_table_id" {}

variable "source_cidr_blocks" {
  type                    = list
}

variable "ssh_source_cidr_blocks" {
  type                    = list
}

variable "websvr_listen_ports" {
  type                    = map(list(number))
}

variable "common_tags" {}
