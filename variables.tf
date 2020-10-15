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

/*
variable "proxy_config" {
  type = object({
    service_name      = string
    port_mappings     = list(object({
      name            = string
      description     = string
      backend_host    = string
      backend_port    = number
      nlb_port        = number
      proxy_port      = number
    }))
  })

  default = {
    service_name = "myhaproxy"
    port_mappings = [
      {
        name = "websvr-ssh"
        description = "ssh connnection to websvr"
        backend_host = "PLACEHOLDER.SERVER"
        backend_port = 22
        nlb_port = 9022
        proxy_port = 9022
      },
      {
        name = "websvr-http"
        description = "http connnection to websvr"
        backend_host = "PLACEHOLDER.SERVER"
        backend_port = 8080
        nlb_port = 9080
        proxy_port = 9080
      },
      {
        name = "websvr-https"
        description = "https connnection to websvr"
        backend_host = "PLACEHOLDER.SERVER"
        backend_port = 8443
        nlb_port = 9443
        proxy_port = 9443
      }
    ]
  }
}
*/

/*
variable "proxy_listen_http_port" {
  type          = string
  default       = "9080"
  description   = "HAProxy Listen Port for HTTP, e.g. 8888"
}

variable "proxy_listen_https_port" {
  type          = string
  default       = "9443"
  description   = "HAProxy Listen Port for HTTPS, e.g. 8443"
}

variable "proxy_listen_ssh_port" {
  type          = string
  default       = "9022"
  description   = "HAProxy Listen Port for SSH, e.g. 2222"
}

variable "nlb_listen_http_port" {
  type          = string
  default       = "80"
  description   = "NLB Listen Port for HTTP, e.g. 80"
}

variable "nlb_listen_https_port" {
  type          = string
  default       = "443"
  description   = "NLB Listen Port for HTTPS, e.g. 443"
}

variable "nlb_listen_ssh_port" {
  type          = string
  default       = "22"
  description   = "NLB Listen Port for SSH, e.g. 22"
}

variable "nlb_listen_ecs_http_port" {
  type          = string
  default       = "88"
  description   = "NLB Listen Port for ECS HTTP, e.g. 88"
}

variable "nlb_listen_ecs_https_port" {
  type          = string
  default       = "88"
  description   = "NLB Listen Port for ECS HTTP, e.g. 88"
}

variable "nlb_listen_ecs_ssh_port" {
  type          = string
  default       = "88"
  description   = "NLB Listen Port for ECS HTTP, e.g. 88"
}
*/