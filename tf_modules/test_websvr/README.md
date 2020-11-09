# Module: test\_websvr

This module can be used to create a webserver instance to assist in testing  
of HAProxy cluster (refer to diagram to see where websvr is located). Also, refer to  
websvr\_userdata.tpl file to view the EC2 instance user data script, in order to  
understand how Python based and Nginx webserver listeners are deployed.

### Usage:

```hcl
module "test_websvr" {
  source = "./tf_modules/test_websvr"

  aws_region            = "us-east-1"
  app_shortcode         = "prt"

  ec2_ami_id            = data.aws_ami.ec2_ami.id
  ec2_instance_type     = "m5.large"
  ec2_ssh_keypair_name  = "my_ssh_keypair"

  vpc_id                = aws_vpc.my_backend_vpc.id
  subnet_id             = aws_subnet.my_backend_vpc_subnet1.id
  s3_endpoint_enabled   = true
  vpc_route_table_id    = aws_vpc.my_backend_vpc.main_route_table_id
  source_cidr_blocks    = [ aws_vpc.my_non_routable_vpc.cidr_block ]
  ssh_source_cidr_blocks= ["0.0.0.0/0"]

  dns_zone_id           = aws_route53_zone.dns_zone.zone_id
  dns_custom_hostname   = "websvr"

  websvr_listen_ports   = {
    server_http_ports   = [ 8080, 8081 ] # runs python webservers in http mode
    server_https_ports  = [ 8443, 8444 ] # runs python webservers in https mode
    server_ssh_ports    = [ 22 ] # currently only sshd at port 22 is supported
    nginx_http_ports    = [ 9090, 9091 ] # runs nginx listeners in http mode
    nginx_https_ports   = [ 9443, 9444 ] # runs nginx listeners in https mode
  }

  common_tags           = local.common_tags
}
```

## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws\_region | Specify the AWS region to be used for resource creations | `string` | `"us-east-1"` | no |
| app\_shortcode | Specify a short-code or pneumonic for this application or project | `string` | n/a | yes |
| vpc\_id | Specify a VPC ID where the client ec2 instance will be deployed | `string` | n/a | yes |
| subnet\_id | Specify a Subnet ID for the client ec2 instance | `string` | n/a | yes |
| ec2\_ami\_id | Specify an AMI ID to be used for EC2 instance creation | `string` | n/a | yes |
| ec2\_instance\_type | Specify EC2 instance type, e.g. m5.large | `string` | `"m5.large"` | no |
| ec2\_ssh\_keypair\_name | Specify name of an existing EC2 keypair, e.g. my\_key | `string` | n/a | yes |
| ssh\_source\_cidr\_blocks | Specify list of source CIDR ranges for security group's SSH ingress | `list` | n/a | yes |
| source\_cidr\_blocks | Specify list of source CIDR ranges for security group's ingress rules | `list` | n/a | yes |
| s3\_endpoint\_enabled | If true, an S3 VPC endpoint (Gateway style) will be created to enable access to Amazon Linux yum repos | `bool` | `false` | no |
| vpc\_route\_table\_id | Specify a Route Table ID associated with the VPC where client instance is deployed; this enables route to S3 VPC endpoint | `string` | `null` | no |
| dns\_zone\_id | Specify a Route53 private DNS Zone ID for creating alias records | `string` | n/a | yes |
| dns\_custom\_hostname | Specify a custom DNS record name to map to this client instance | `string` | n/a | yes |
| websvr\_listen\_ports | Specify a map of ports to be used for one or more webserver listeners | <pre>object({<br>    server_http_ports     = list(number)<br>    server_https_ports    = list(number)<br>    server_ssh_ports      = list(number)<br>    nginx_http_ports      = list(number)<br>    nginx_https_ports     = list(number)    <br>  })</pre> | n/a | yes |
| common\_tags | Specify a map of tags to be used for resource tagging | `map` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| private\_dns | Private DNS name associated with this webserver instance |
| private\_ip | Private IP address associated with this webserver instance |
| public\_dns | Private DNS name associated with this webserver instance |
| alias\_dns | FQDN of alias DNS name associated with this webserver instance |
| instance\_id | EC2 instance id of this webserver |

