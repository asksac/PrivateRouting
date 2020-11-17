variable "aws_profile" {
  type                    = string
  default                 = "default"
  description             = "Specify an aws profile name to be used for access credentials (run `aws configure help` for more information on creating a new profile)"
}

variable "aws_region" {
  type                    = string
  default                 = "us-east-1"
  description             = "Specify the AWS region to be used for resource creations"
}

variable "app_name" {
  type                    = string
  default                 = "PrivateRouting"
  description             = "Specify an application or project name, used primarily for tagging as well as searching for custom AMI id"
}

variable "app_shortcode" {
  type                    = string
  default                 = "prt"
  description             = "Specify a short-code or pneumonic for this application or project"
}

variable "aws_env" {
  type                    = string
  default                 = "dev"
  description             = "Specify a value for the Environment tag"
}

variable "ec2_ssh_enabled" {
  type                    = bool 
  default                 = false
  description             = "Specify whether ssh access into ec2 instances are enabled"
}

variable "ec2_ssh_keypair_name" {
  type                    = string
  default                 = null 
  description             = "Specify name of an existing keypair for SSH access into ec2 instances, e.g. my_key"
}

variable "ecr_proxy_image_repo_name" {
  type                    = string
  default                 = "haproxy-registry" 
  description             = "Specify ECR repository name for storing HAProxy container image"
}

variable "ecr_proxy_image_tag" {
  type                    = string
  default                 = "latest" 
  description             = "Specify ECR image tag to be used for pulling HAProxy container image"
}

## VPC #1 ##

# using an RFC 1918 reserved IP range
variable "vpc1_cidr" {
  type                    = string
  default                 = "10.0.0.0/16"
  description             = "Specify CIDR range for VPC 1 (simulating non_routable_vpc)"
}

variable "vpc1_name" {
  type                    = string
  default                 = "vpc1"
  description             = "Specify a name for VPC 1 for labeling purposes"
}

variable "vpc1_subnet_priv1_cidr" {
  type                    = string
  default                 = "10.0.1.0/24"
  description             = "Specify a CIDR range for first private subnet within VPC 1"
}

variable "vpc1_subnet_priv1_name" {
  type                    = string
  default                 = "vpc1_priv1"
  description             = "Specify a name for first private subnet for labeling purposes"
}

variable "vpc1_subnet_priv2_cidr" {
  type                    = string
  default                 = "10.0.2.0/24"
  description             = "Specify a CIDR range for second private subnet within VPC 1"
}

variable "vpc1_subnet_priv2_name" {
  type                    = string
  default                 = "vpc1_priv2"
  description             = "Specify a name for second private subnet for labeling purposes"
}

## VPC #2 ##

# using an RFC 1918 reserved IP range
variable "vpc2_cidr" {
  type                    = string
  default                 = "172.16.0.0/16"
  description             = "Specify CIDR range for VPC 2 (simulating routable_vpc)"
}

variable "vpc2_name" {
  type                    = string
  default                 = "vpc2"
  description             = "Specify a name for VPC 2 for labeling purposes"
}

variable "vpc2_subnet_priv1_cidr" {
  type                    = string
  default                 = "172.16.1.0/24"
  description             = "Specify a CIDR range for first private subnet within VPC 2"
}

variable "vpc2_subnet_priv1_name" {
  type                    = string
  default                 = "vpc2_priv1"
  description             = "Specify a name for first private subnet for labeling purposes"
}

variable "vpc2_subnet_priv2_cidr" {
  type                    = string
  default                 = "172.16.3.0/24"
  description             = "Specify a CIDR range for second private subnet within VPC 2"
}

variable "vpc2_subnet_priv2_name" {
  type                    = string
  default                 = "vpc2_priv2"
  description             = "Specify a name for second private subnet for labeling purposes"
}

## VPC #3 ##

variable "vpc3_cidr" {
  type                    = string
  default                 = "192.168.0.0/16" 
  description             = "Specify CIDR range for VPC 3 (simulating backend_vpc)"
}

variable "vpc3_name" {
  type                    = string
  default                 = "vpc3"
  description             = "Specify a name for VPC 3 for labeling purposes"
}

variable "vpc3_subnet_pub1_cidr" {
  type                    = string
  default                 = "192.168.1.0/24" 
  description             = "Specify a CIDR range for first public subnet within VPC 3"
}

variable "vpc3_subnet_pub1_name" {
  type                    = string
  default                 = "vpc3_pub1"
  description             = "Specify a name for first public subnet for labeling purposes"
}

## WebServer Addon Rule Setup ##

# Note: For Testing Only 
# This enables a direct forwarding rule from NLB (proxy_ec2) to WebSvr, bypassing 
# HAProxy. It serves as a baseline for comparing performance impact of HAProxy 
# during load testing.  

variable "addon_nlb_port" {
  type                    = number
  default                 = 10080
  description             = "Specify an nlb listener port for direct bypass forwarding rule"
}

variable "addon_websvr_port" {
  type                    = number
  default                 = 8080
  description             = "Specify the backend webserver port to use for direct bypass rule"
}