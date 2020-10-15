variable "aws_region" {
  default = "us-east-1"
}

variable "app_name" {
  default = "PrivateRouting"
}

variable "app_shortcode" {
  default = "prt"
}

variable "vpc_id" {}

variable "subnet_id" {}

variable "source_cidr_blocks" {
  type = list
}

variable "proxy_config" {
  type = object({
    service_name      = string
    port_mappings     = map(object({
      description     = string
      backend_host    = string
      backend_port    = number
      nlb_port        = number
      proxy_port      = number
    }))
  })
}

variable "common_tags" {}
