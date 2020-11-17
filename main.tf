/**
 * # Root Terraform Module
 *
 * The root Terraform module in this repository can be used to create a full demo environment running an HAProxy cluster on ECS for Fargate, as well as on an EC2 cluster. The environment uses a 3 VPC setup, and also creates a test client and test webserver instances. 
 * 
 * The demo environment created will look similar to that shown in the following diagram: 
 * ![AWS VPC network diagram](./docs/images/aws_vpc_diagram.png)
 * 
 * The default configuration for the demo environment is based on variables and values defined in variables.tf and locals.tf files. You may modify that or create a terraform.tfvars file to specify custom values. 
 * 
 */

terraform {
  required_version    = ">= 0.13"
  required_providers {
    aws               = ">= 3.11.0"
  }
}

provider "aws" {
  profile   = var.aws_profile
  region    = var.aws_region
}

#
# Defines data source for our custom ami created using packer 
# Refer: build/ami_build.pkr.hcl
#
data "aws_ami" "ec2_ami" {
  most_recent = true
  owners      = ["self"]

  filter {
    name      = "name"
    values    = ["${var.app_name}-*"]
  }
}

#
# Creates an ECR repository for storing HAProxy docker container image 
#
resource "aws_ecr_repository" "registry" {
  name                        = var.ecr_proxy_image_repo_name
  image_tag_mutability        = "MUTABLE"

  image_scanning_configuration {
    scan_on_push              = false
  }

  lifecycle {
    #prevent_destroy           = true
  }

  tags                        = local.common_tags
}

# 
# Creates a Route53 DNS zone for custom domain records
#
resource "aws_route53_zone" "dns_zone" {
  name                      = "${var.app_shortcode}.internal"
  comment                   = "Private DNS zone for mapping internal domain names for application ${var.app_name}"

  vpc {
    vpc_id                  = aws_vpc.vpc1.id
  }

  vpc {
    vpc_id                  = aws_vpc.vpc2.id
  }

  vpc {
      vpc_id                = aws_vpc.vpc3.id
  }
}

#
# Output values
#
output "ec2_ami_arn" {
  value                     = data.aws_ami.ec2_ami.arn
  description               = "AMI ARN used for EC2 instance creation"
}

output "proxy_image_repo" {
  value                     = aws_ecr_repository.registry.repository_url
  description               = "ECR repository image URI for HAProxy container image"
}

output "dns_zone_name" {
  value                     = aws_route53_zone.dns_zone.name
  description               = "Base domain name under which all alias dns records are created"
}