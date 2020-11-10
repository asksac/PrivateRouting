# Root Terraform Module

The root Terraform module in this repository can be used to create a full demo environment running an HAProxy cluster on ECS for Fargate, as well as on an EC2 cluster. The environment uses a 3 VPC setup, and also creates a test client and test webserver instances.

The demo environment created will look similar to that shown in the following diagram:
![AWS VPC network diagram](./docs/images/aws\_vpc\_diagram.png)

The default configuration for the demo environment is based on variables and values defined in variables.tf and locals.tf files. You may modify that or create a terraform.tfvars file to specify custom values.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 0.13 |
| aws | >= 3.11.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 3.11.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws\_profile | Specify an aws profile name to be used for access credentials (run `aws configure help` for more information on creating a new profile) | `string` | `"default"` | no |
| aws\_region | Specify the AWS region to be used for resource creations | `string` | `"us-east-1"` | no |
| app\_name | Specify an application or project name, used primarily for tagging as well as searching for custom AMI id | `string` | `"PrivateRouting"` | no |
| app\_shortcode | Specify a short-code or pneumonic for this application or project | `string` | `"prt"` | no |
| aws\_env | Specify a value for the Environment tag | `string` | `"dev"` | no |
| ec2\_ssh\_keypair\_name | Specify name of an existing keypair for SSH access into EC2 instances | `string` | n/a | yes |
| vpc1\_cidr | Specify CIDR range for VPC 1 (simulating non\_routable\_vpc) | `string` | `"10.0.0.0/16"` | no |
| vpc1\_name | Specify a name for VPC 1 for labeling purposes | `string` | `"vpc1"` | no |
| vpc1\_subnet\_priv1\_cidr | Specify a CIDR range for first private subnet within VPC 1 | `string` | `"10.0.1.0/24"` | no |
| vpc1\_subnet\_priv1\_name | Specify a name for first private subnet for labeling purposes | `string` | `"vpc1_priv1"` | no |
| vpc1\_subnet\_priv2\_cidr | Specify a CIDR range for second private subnet within VPC 1 | `string` | `"10.0.2.0/24"` | no |
| vpc1\_subnet\_priv2\_name | Specify a name for second private subnet for labeling purposes | `string` | `"vpc1_priv2"` | no |
| vpc2\_cidr | Specify CIDR range for VPC 2 (simulating routable\_vpc) | `string` | `"172.16.0.0/16"` | no |
| vpc2\_name | Specify a name for VPC 2 for labeling purposes | `string` | `"vpc2"` | no |
| vpc2\_subnet\_priv1\_cidr | Specify a CIDR range for first private subnet within VPC 2 | `string` | `"172.16.1.0/24"` | no |
| vpc2\_subnet\_priv1\_name | Specify a name for first private subnet for labeling purposes | `string` | `"vpc2_priv1"` | no |
| vpc2\_subnet\_priv2\_cidr | Specify a CIDR range for second private subnet within VPC 2 | `string` | `"172.16.3.0/24"` | no |
| vpc2\_subnet\_priv2\_name | Specify a name for second private subnet for labeling purposes | `string` | `"vpc2_priv2"` | no |
| vpc3\_cidr | Specify CIDR range for VPC 3 (simulating backend\_vpc) | `string` | `"192.168.0.0/16"` | no |
| vpc3\_name | Specify a name for VPC 3 for labeling purposes | `string` | `"vpc3"` | no |
| vpc3\_subnet\_pub1\_cidr | Specify a CIDR range for first public subnet within VPC 3 | `string` | `"192.168.1.0/24"` | no |
| vpc3\_subnet\_pub1\_name | Specify a name for first public subnet for labeling purposes | `string` | `"vpc3_pub1"` | no |
| addon\_nlb\_port | Specify an nlb listener port for direct bypass forwarding rule | `number` | `10080` | no |
| addon\_websvr\_port | Specify the backend webserver port to use for direct bypass rule | `number` | `8080` | no |

## Outputs

| Name | Description |
|------|-------------|
| webserver\_details | DNS values of Test WebServer instance |
| client\_details | DNS values of Test Client instance |
| proxy\_ecs | DNS values of NLB and Endpoint associated with HAProxy on ECS cluster |
| proxy\_ec2 | DNS values of NLB and Endpoint associated with HAProxy on EC2 cluster |

