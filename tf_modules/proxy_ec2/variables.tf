variable "aws_region" {
  type                    = string
  default                 = "us-east-1"
  description             = "Specify the AWS region to be used for resource creations"
}

variable "app_name" {
  type                    = string
  description             = "Specify the application or project name this module is part of"
}

variable "app_shortcode" {
  type                    = string
  description             = "Specify a short-code or pneumonic for this application or project"
}

variable "vpc_id" {
  type                    = string
  description             = "Specify a VPC ID where this module will be deployed"
}

variable "subnet_ids" {
  type                    = list 
  description             = "Specify a list of Subnet IDs where this module will be deployed"
}

variable "dns_zone_id" {
  type                    = string
  description             = "Specify a Route53 private DNS Zone ID for creating alias records"
}

variable "dns_custom_hostname" {
  type                    = string
  description             = "Specify a custom DNS record name to map to NLB"
}

variable "ec2_ami_id" {
  type                    = string
  description             = "Specify an AMI ID to be used for EC2 instance creation"
}

variable "instance_type" {
  type                    = string
  default                 = "c5.large"
  description             = "Specify EC2 instance type, e.g. c5.large"
}

variable "ec2_ssh_enabled" {
  type                    = bool 
  default                 = false
  description             = "Specify whether ssh access into proxy ec2 instances are enabled"
}

variable "ec2_ssh_keypair_name" {
  type                    = string
  description             = "Specify name of an existing EC2 keypair, e.g. my_key"
}

variable "source_cidr_blocks" {
  type                    = list
  description             = "Specify list of source CIDR ranges for security group's ingress rules"
}

variable "ecr_registry_id" {
  type                    = string
  description             = "Specify ECR Registry ID where HAProxy container image is stored"
}

variable "ecr_image_uri" {
  type                    = string
  description             = "Specify the HAProxy ECR container image URI with tag"
}

variable "min_cluster_size" {
  type                    = number
  default                 = 1
  description             = "Specify minimum number of instances maintained in the proxy cluster"
}

variable "max_cluster_size" {
  type                    = number
  default                 = 8
  description             = "Specify maximum number of instances allowed in the proxy cluster"
}

variable "autoscaling_low_cpu_mark" {
  type                    = number
  default                 = 20
  description             = "Specify the low CPU utilization watermark for cluster scale-in"
}

variable "autoscaling_high_cpu_mark" {
  type                    = number
  default                 = 70
  description             = "Specify the high CPU utilization watermark for cluster scale-out"
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
