variable "aws_region" {
  default                 = "us-east-1"
}

variable "app_name" {}

variable "app_shortcode" {}

variable "vpc_id" {}

variable "subnet_ids" {
   type                   = list 
}

variable "dns_zone_id" {}

variable "ec2_ami_id" {}

variable "instance_type" {
  default                 = "c5.large"
}

variable "ecr_registry_id" {
  description         = "ECR Registry ID, which is also ECR Docker FQDN prefix"
}

variable "ecr_image_uri" {
  description         = "HAProxy Docker ECR container image URI with tag"
}

variable "source_cidr_blocks" {
  type                    = list
}

variable "min_cluster_size" {
  type                    = number
  default                 = 1
}

variable "max_cluster_size" {
  type                    = number
  default                 = 8
}

variable "autoscaling_high_cpu_mark" {
  type                    = number
  default                 = 70
}

variable "autoscaling_low_cpu_mark" {
  type                    = number
  default                 = 20
}

variable "ec2_ssh_keypair_name" {
  type                    = string
  description             = "Specify name of an existing EC2 keypair, e.g. my_key"
}

variable "proxy_config" {
  type = object({
    service_name          = string
    port_mappings         = map(object({
      description         = string
      backend_host        = string
      backend_port        = number
      nlb_port            = number
      proxy_port          = number
    }))
  })
}

variable "common_tags" {}
