variable "aws_region" {
  default                 = "us-east-1"
}

variable "app_shortcode" {}

variable "vpc_id" {}

variable "subnet_id" {}

variable "vpc_route_table_id" {}

variable "dns_zone_id" {}

variable "ec2_ami_id" {}

variable "ec2_instance_type" {
  default                 = "m5.large"
}

variable "ec2_ssh_keypair_name" {}

variable "source_cidr_blocks" {
  type                    = list
}

variable "common_tags" {}