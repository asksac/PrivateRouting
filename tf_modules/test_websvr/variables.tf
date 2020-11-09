variable "aws_region" {
  type                    = string
  default                 = "us-east-1"
  description             = "Specify the AWS region to be used for resource creations"
}

variable "app_shortcode" {
  type                    = string
  description             = "Specify a short-code or pneumonic for this application or project"
}

variable "vpc_id" {
  type                    = string
  description             = "Specify a VPC ID where the client ec2 instance will be deployed"
}

variable "subnet_id" {
  type                    = string 
  description             = "Specify a Subnet ID for the client ec2 instance"
}

variable "ec2_ami_id" {
  type                    = string
  description             = "Specify an AMI ID to be used for EC2 instance creation"
}

variable "ec2_instance_type" {
  type                    = string
  default                 = "m5.large"
  description             = "Specify EC2 instance type, e.g. m5.large"
}

variable "ec2_ssh_keypair_name" {
  type                    = string
  description             = "Specify name of an existing EC2 keypair, e.g. my_key"
}

variable "ssh_source_cidr_blocks" {
  type                    = list
  description             = "Specify list of source CIDR ranges for security group's SSH ingress"
}

variable "source_cidr_blocks" {
  type                    = list
  description             = "Specify list of source CIDR ranges for security group's ingress rules"
}

variable "s3_endpoint_enabled" {
  type                    = bool 
  default                 = false
  description             = "If true, an S3 VPC endpoint (Gateway style) will be created to enable access to Amazon Linux yum repos"
}

variable "vpc_route_table_id" {
  type                    = string
  default                 = null 
  description             = "Specify a Route Table ID associated with the VPC where client instance is deployed; this enables route to S3 VPC endpoint"
}

variable "dns_zone_id" {
  type                    = string
  description             = "Specify a Route53 private DNS Zone ID for creating alias records"
}

variable "dns_custom_hostname" {
  type                    = string
  description             = "Specify a custom DNS record name to map to this client instance"
}

variable "websvr_listen_ports" {
  type                    = object({
    server_http_ports     = list(number)
    server_https_ports    = list(number)
    server_ssh_ports      = list(number)
    nginx_http_ports      = list(number)
    nginx_https_ports     = list(number)    
  })
  description             = "Specify a map of ports to be used for one or more webserver listeners"
}

variable "common_tags" {
  type                    = map
  description             = "Specify a map of tags to be used for resource tagging"
}
