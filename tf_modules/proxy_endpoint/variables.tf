variable "app_shortcode" {
  default                 = "prt"
}

variable "vpc" {
  type                    = object({
    id                    = string
    cidr_block            = string 
  })
}

variable "subnet_ids" {
  type                    = list
}

variable "dns_zone_id" {}

variable "dns_custom_hostname" {
  description             = "Specify a custom Route53 record name to map to this VPC endpoint"
}

variable "endpoint_name" {}

variable "endpoint_service_name" {}

variable "proxy_config" {
  type = object({
    service_name          = string
    port_mappings         = list(object({
      name                = string
      description         = string
      backend_host        = string
      backend_port        = number
      nlb_port            = number
      proxy_port          = number
    }))
  })
}

variable "common_tags" {}