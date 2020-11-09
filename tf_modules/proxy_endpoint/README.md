# Module: proxy\_endpoint

This module assists in creating a VPC endpoint associated with a specified Endpoint  
Service, such as a Network Load Balancer.

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app\_shortcode | Specify a short-code or pneumonic for this application or project | `string` | n/a | yes |
| endpoint\_service\_name | Specify the Endpoint Service's name to attach to this VPC endpoint | `string` | n/a | yes |
| vpc\_id | Specify a VPC ID where the VPC endpoint will be deployed | `string` | n/a | yes |
| subnet\_ids | Specify a list of Subnet IDs where the VPC endpoint will be enabled | `list` | n/a | yes |
| source\_cidr\_blocks | Specify list of source CIDR ranges for security group's ingress rules | `list` | n/a | yes |
| dns\_zone\_id | Specify a Route53 private DNS Zone ID for creating alias records | `string` | n/a | yes |
| dns\_custom\_hostname | Specify a custom DNS record name to map to this VPC endpoint | `string` | n/a | yes |
| proxy\_config | Specify proxy's configuration consisting of a unique name and a list of port mapping rules | <pre>object({<br>    service_name          = string<br>    port_mappings         = list(object({<br>      name                = string<br>      description         = string<br>      backend_host        = string<br>      backend_port        = number<br>      nlb_port            = number<br>      proxy_port          = number<br>    }))<br>  })</pre> | n/a | yes |
| common\_tags | Specify a map of tags to be used for resource tagging | `map` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| endpoint\_dns | List of Private DNS entries associated with this VPC endpoint |
| security\_group\_id | Security Group ID associated with this VPC endpoint |
| alias\_dns | FQDN of alias DNS record associated with this VPC endpoint |

