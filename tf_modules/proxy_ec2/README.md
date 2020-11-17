# Module: proxy\_ec2

This module can be used to deploy an HAProxy cluster running on EC2 instances, and managed by an EC2 Auto Scaling group. Each instance of the module can support upto 50 port mappings in the proxy configuration.

### Usage:

```hcl
module "proxy_ec2" {
  source                    = "./tf_modules/proxy_ec2"

  aws_region                = "us-east-1"
  app_name                  = "PrivateRouting"
  app_shortcode             = "prt"

  vpc_id                    = aws_vpc.my_routable_vpc.id
  subnet_ids                = [ aws_subnet.my_routable_vpc_subnet1.id, aws_subnet.my_routable_vpc_subnet2.id ]

  dns_zone_id               = aws_route53_zone.my_dns_zone.zone_id
  dns_custom_hostname       = "myproxy"

  ec2_ami_id                = data.aws_ami.ec2_ami.id
  instance_type             = "t3.medium"
  ec2_ssh_enabled           = true
  ec2_ssh_keypair_name      = "my_ssh_keypair"
  ssh_source_cidr_blocks    = [ aws_vpc.my_bastion_vpc.cidr_block ]
  source_cidr_blocks        = [ aws_vpc.my_routable_vpc.cidr_block ]

  ecr_registry_id           = aws_ecr_repository.my_registry.registry_id
  ecr_image_uri             = "${aws_ecr_repository.my_registry.repository_url}:latest"

  min_cluster_size          = 1
  max_cluster_size          = 4
  autoscaling_low_cpu_mark  = 25
  autoscaling_high_cpu_mark = 75

  proxy_config              = {
    service_name            = "myec2proxy"
    port_mappings           = [
      {
        name                = "api_svc"
        description         = "HTTPS connection to backend API service"
        backend_host        = "api.corp.mydomain.net"
        backend_port        = 443
        nlb_port            = 8443
        proxy_port          = 8443
      },
      {
        name                = "sftp_svr"
        description         = "SFTP connection to backend file server"
        backend_host        = "filesvr.corp.mydomain.net"
        backend_port        = 22
        nlb_port            = 7022
        proxy_port          = 7022
      }
    ]
  }

  common_tags               = local.common_tags
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.12 |
| aws | >= 3.11.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.11.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws\_region | Specify the AWS region to be used for resource creations | `string` | `"us-east-1"` | no |
| app\_name | Specify the application or project name this module is part of | `string` | n/a | yes |
| app\_shortcode | Specify a short-code or pneumonic for this application or project | `string` | n/a | yes |
| vpc\_id | Specify a VPC ID where this module will be deployed | `string` | n/a | yes |
| subnet\_ids | Specify a list of Subnet IDs where this module will be deployed | `list` | n/a | yes |
| dns\_zone\_id | Specify a Route53 private DNS Zone ID for creating alias records | `string` | n/a | yes |
| dns\_custom\_hostname | Specify a custom DNS record name to map to NLB | `string` | n/a | yes |
| ec2\_ami\_id | Specify an AMI ID to be used for EC2 instance creation | `string` | n/a | yes |
| instance\_type | Specify EC2 instance type, e.g. c5.large | `string` | `"c5.large"` | no |
| ec2\_ssh\_enabled | Specify whether ssh access into proxy ec2 instances are enabled | `bool` | `false` | no |
| ec2\_ssh\_keypair\_name | Specify name of an existing EC2 keypair, e.g. my\_key | `string` | `null` | no |
| ssh\_source\_cidr\_blocks | Specify list of source CIDR ranges for security group's SSH ingress | `list` | `null` | no |
| source\_cidr\_blocks | Specify list of source CIDR ranges for security group's ingress rules | `list` | n/a | yes |
| ecr\_registry\_id | Specify ECR Registry ID where HAProxy container image is stored | `string` | n/a | yes |
| ecr\_image\_uri | Specify the HAProxy ECR container image URI with tag | `string` | n/a | yes |
| min\_cluster\_size | Specify minimum number of instances maintained in the proxy cluster | `number` | `1` | no |
| max\_cluster\_size | Specify maximum number of instances allowed in the proxy cluster | `number` | `8` | no |
| autoscaling\_low\_cpu\_mark | Specify the low CPU utilization watermark for cluster scale-in | `number` | `20` | no |
| autoscaling\_high\_cpu\_mark | Specify the high CPU utilization watermark for cluster scale-out | `number` | `70` | no |
| proxy\_config | Specify proxy's configuration consisting of a unique name and a list of port mapping rules | <pre>object({<br>    service_name          = string<br>    port_mappings         = list(object({<br>      name                = string<br>      description         = string<br>      backend_host        = string<br>      backend_port        = number<br>      nlb_port            = number<br>      proxy_port          = number<br>    }))<br>  })</pre> | n/a | yes |
| common\_tags | Specify a map of tags to be used for resource tagging | `map` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| nlb\_arn | ARN of Network Load Balancer fronting the HAProxy cluster |
| nlb\_dns | DNS name of Network Load Balancer fronting the HAProxy cluster |
| nlb\_alias\_fqdn | FQDN of alias DNS record associated with the Network Load Balancer |
| security\_group\_id | Security Group ID associated with the HAProxy cluster |
| endpoint\_service\_name | VPC Endpoint Service Name of the Network Load Balancer |

