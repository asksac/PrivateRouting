# Module: proxy\_endpoint

This module assists in creating a VPC endpoint associated with a specified Endpoint Service, such as a Network Load Balancer.

### Usage:

```hcl
module "ecs_proxy_endpoint" {
  source                    = "./tf_modules/proxy_endpoint"

  app_shortcode             = "prt"

  endpoint_service_name     = module.proxy_ecs.endpoint_service_name
  vpc_id                    = aws_vpc.my_non_routable_vpc.id
  subnet_ids                = [ aws_subnet.my_non_routable_vpc_subnet1.id ]
  source_cidr_blocks        = [ aws_vpc.my_non_routable_vpc.cidr_block ]

  dns_zone_id               = aws_route53_zone.dns_zone.zone_id
  dns_custom_hostname       = "proxy-ecs-endpoint"

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

