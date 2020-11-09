# Module: proxy\_ecs

This module can be used to deploy HAProxy running on an ECS Fargate cluster, with capacity automatically managed based on specified min and max cluster sizes, and auto-scaling low and high cpu marks. Each module can support up to 50 `port_mappings` rules specified through `proxy_config` variable. Module will create multiple ECS Services, one for every 5 port mapping rules.

### Usage:

```hcl
module "proxy_ecs" {
  source                    = "./tf_modules/proxy_ecs"

  aws_region                = "us-east-1"
  app_name                  = "PrivateRouting"
  app_shortcode             = "prt"

  vpc_id                    = aws_vpc.my_routable_vpc.id
  subnet_ids                = [ aws_subnet.my_routable_vpc_subnet1.id ]

  dns_zone_id               = aws_route53_zone.my_dns_zone.zone_id
  dns_custom_hostname       = "myproxy"

  source_cidr_blocks        = [ aws_vpc.my_non_routable_vpc.cidr_block ]
  ecr_image_uri             = "${aws_ecr_repository.my_registry.repository_url}:1.0"

  min_cluster_size          = 1
  max_cluster_size          = 4
  autoscaling_low_cpu_mark  = 25
  autoscaling_high_cpu_mark = 75

  proxy_config              = {
    service_name            = "myproxy"
    port_mappings           = [
      {
        name                = "api_svc"
        description         = "Connection to backend API service"
        backend_host        = "api.corp.mydomain.net"
        backend_port        = 443
        nlb_port            = 8443
        proxy_port          = 8443
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
| source\_cidr\_blocks | Specify list of source CIDR ranges for security group's ingress rules | `list` | n/a | yes |
| ecr\_image\_uri | Specify the HAProxy ECR container image URI with tag | `string` | n/a | yes |
| min\_cluster\_size | Specify minimum number of tasks maintained in the proxy cluster | `number` | `2` | no |
| max\_cluster\_size | Specify maximum number of tasks allowed in the proxy cluster | `number` | `8` | no |
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

