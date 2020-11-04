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

variable "subnet_ids" {
  type = list
}

variable "dns_zone_id" {}

variable "source_cidr_blocks" {
  type = list
}

variable "ecr_image_uri" {
  description         = "HAProxy Docker ECR container image URI with tag"
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

variable "ecs_low_cpu_mark" {
  default = "20"
}

variable "ecs_high_cpu_mark" {
  default = "70"
}

variable "ecs_autoscale_min_instances" {
  default = "2"
}

variable "ecs_autoscale_max_instances" {
  default = "8"
}

variable "common_tags" {}
