# Module: test\_client

This module can be used to create a client ec2 instance to assist in testing  
of HAProxy cluster (refer to diagram to see where client instance is located).  
By default, the client instance has `httpd-tools` installed. This provides access  
to utilities such as Apache Bench (for load testing).

### Usage:

```hcl
module "test_client" {
  source = "./tf_modules/test_client"

  aws_region            = "us-east-1"
  app_shortcode         = "prt"

  ec2_ami_id            = data.aws_ami.ec2_ami.id
  ec2_instance_type     = "m5.large"
  ec2_ssh_keypair_name  = "my_ssh_keypair"

  vpc_id                = aws_vpc.my_non_routable_vpc.id
  subnet_id             = aws_subnet.my_non_routable_vpc_subnet1.id
  s3_endpoint_enabled   = true
  vpc_route_table_id    = aws_vpc.my_non_routable_vpc.main_route_table_id
  source_cidr_blocks    = [ aws_vpc.my_bastion_vpc.cidr_block ]

  dns_zone_id           = aws_route53_zone.dns_zone.zone_id
  dns_custom_hostname   = "client"
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
| source\_cidr\_blocks | Specify list of source CIDR ranges for security group's ingress rules | `list` | n/a | yes |
| s3\_endpoint\_enabled | If true, an S3 VPC endpoint (Gateway style) will be created to enable access to Amazon Linux yum repos | `bool` | `false` | no |
| vpc\_route\_table\_id | Specify a Route Table ID associated with the VPC where client instance is deployed; this enables route to S3 VPC endpoint | `string` | `null` | no |
| dns\_zone\_id | Specify a Route53 private DNS Zone ID for creating alias records | `string` | n/a | yes |
| dns\_custom\_hostname | Specify a custom DNS record name to map to this client instance | `string` | n/a | yes |
| common\_tags | Specify a map of tags to be used for resource tagging | `map` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| private\_dns | Private DNS name associated with this client ec2 instance |
| public\_dns | Public DNS name associated with this client ec2 instance, if available |
| alias\_dns | FQDN of alias DNS name associated with this client ec2 instance |

