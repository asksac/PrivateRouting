variable "aws_profile" {
  type    = string
  default = "terraform"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "app_name" {
  type          = string
  default       = "PrivateRouting"
}

variable "app_shortcode" {
  type          = string
  default       = "privrt"
}

variable "ec2_ssh_keypair_name" {
  type          = string
  description   = "Specify name of an existing EC2 keypair, e.g. my_key"
}

## VPC #1 ##

# using an RFC 1918 reserved IP range
variable "vpc1_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "vpc1_name" {
  type    = string
  default = "vpc1"
}

variable "vpc1_subnet_priv1_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "vpc1_subnet_priv1_name" {
  type    = string
  default = "vpc1_priv1"
}

variable "vpc1_subnet_priv2_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "vpc1_subnet_priv2_name" {
  type    = string
  default = "vpc1_priv2"
}

## VPC #2 ##

# using an RFC 1918 reserved IP range
variable "vpc2_cidr" {
  type    = string
  default = "172.16.0.0/16"
}

variable "vpc2_name" {
  type    = string
  default = "vpc2"
}

variable "vpc2_subnet_priv1_cidr" {
  type    = string
  default = "172.16.1.0/24"
}

variable "vpc2_subnet_priv1_name" {
  type    = string
  default = "vpc2_priv1"
}

variable "vpc2_subnet_priv2_cidr" {
  type    = string
  default = "172.16.3.0/24"
}

variable "vpc2_subnet_priv2_name" {
  type    = string
  default = "vpc2_priv2"
}

variable "vpc2_subnet_pub1_cidr" {
  type    = string
  default = "172.16.2.0/24"
}

variable "vpc2_subnet_pub1_name" {
  type    = string
  default = "vpc2_pub1"
}

variable "vpc2_subnet_nlb_priv_ip" {
  type    = string
  default = "172.16.1.10"
}

## VPC #3 ##

# using a public IP space for VPC
variable "vpc3_cidr" {
  type    = string
  default = "200.10.0.0/16"
}

variable "vpc3_name" {
  type    = string
  default = "vpc3"
}

variable "vpc3_subnet_pub1_cidr" {
  type    = string
  default = "200.10.1.0/24"
}

variable "vpc3_subnet_pub1_name" {
  type    = string
  default = "vpc3_pub1"
}

## Ports and Proxy Config

variable "websvr_listen_http_port" {
  type          = string
  default       = "8080"
  description   = "WebServer Listen HTTP Port, e.g. 8080"
}

variable "websvr_listen_https_port" {
  type          = string
  default       = "8443"
  description   = "WebServer Listen HTTPS Port, e.g. 8443"
}
