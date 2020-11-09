variable "app_shortcode" {
  type                    = string
  description             = "Specify a short-code or pneumonic for this application or project"
}

variable "endpoint_service_name" {
  type                    = string
  description             = "Specify the Endpoint Service's name to attach to this VPC endpoint"
}

variable "vpc_id" {
  type                    = string
  description             = "Specify a VPC ID where the VPC endpoint will be deployed"
}

variable "subnet_ids" {
  type                    = list 
  description             = "Specify a list of Subnet IDs where the VPC endpoint will be enabled"
}

variable "source_cidr_blocks" {
  type                    = list
  description             = "Specify list of source CIDR ranges for security group's ingress rules"
}

variable "dns_zone_id" {
  type                    = string
  description             = "Specify a Route53 private DNS Zone ID for creating alias records"
}

variable "dns_custom_hostname" {
  type                    = string
  description             = "Specify a custom DNS record name to map to this VPC endpoint"
}

variable "proxy_config" {
  type                    = object({
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
  description             = "Specify proxy's configuration consisting of a unique name and a list of port mapping rules"
}

variable "common_tags" {
  type                    = map
  description             = "Specify a map of tags to be used for resource tagging"
}