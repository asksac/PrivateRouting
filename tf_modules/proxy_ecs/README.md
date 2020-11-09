## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app\_name | Specify the application or project name this module is part of | `string` | n/a | yes |
| app\_shortcode | Specify a short-code or pneumonic for this application or project | `string` | n/a | yes |
| autoscaling\_high\_cpu\_mark | Specify the high CPU utilization watermark for cluster scale-out | `number` | `70` | no |
| autoscaling\_low\_cpu\_mark | Specify the low CPU utilization watermark for cluster scale-in | `number` | `20` | no |
| aws\_region | Specify the AWS region to be used for resource creations | `string` | `"us-east-1"` | no |
| common\_tags | Specify a map of tags to be used for resource tagging | `map` | n/a | yes |
| dns\_custom\_hostname | Specify a custom DNS record name to map to NLB | `string` | n/a | yes |
| dns\_zone\_id | Specify a Route53 private DNS Zone ID for creating alias records | `string` | n/a | yes |
| ecr\_image\_uri | Specify the HAProxy ECR container image URI with tag | `string` | n/a | yes |
| max\_cluster\_size | Specify maximum number of tasks allowed in the proxy cluster | `number` | `8` | no |
| min\_cluster\_size | Specify minimum number of tasks maintained in the proxy cluster | `number` | `2` | no |
| proxy\_config | Specify proxy's configuration consisting of a unique name and a list of port mapping rules | <pre>object({<br>    service_name          = string<br>    port_mappings         = list(object({<br>      name                = string<br>      description         = string<br>      backend_host        = string<br>      backend_port        = number<br>      nlb_port            = number<br>      proxy_port          = number<br>    }))<br>  })</pre> | n/a | yes |
| source\_cidr\_blocks | Specify list of source CIDR ranges for security group's ingress rules | `list` | n/a | yes |
| subnet\_ids | Specify a list of Subnet IDs where this module will be deployed | `list` | n/a | yes |
| vpc\_id | Specify a VPC ID where this module will be deployed | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| endpoint\_service\_name | n/a |
| nlb\_dns | n/a |

