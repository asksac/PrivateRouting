## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| app\_shortcode | n/a | `any` | n/a | yes |
| aws\_region | n/a | `string` | `"us-east-1"` | no |
| common\_tags | n/a | `any` | n/a | yes |
| dns\_custom\_hostname | Specify a custom Route53 record name to map to this websvr instance | `any` | n/a | yes |
| dns\_zone\_id | n/a | `any` | n/a | yes |
| ec2\_ami\_id | n/a | `any` | n/a | yes |
| ec2\_instance\_type | n/a | `string` | `"m5.large"` | no |
| ec2\_ssh\_keypair\_name | n/a | `any` | n/a | yes |
| source\_cidr\_blocks | n/a | `list` | n/a | yes |
| ssh\_source\_cidr\_blocks | n/a | `list` | n/a | yes |
| subnet\_id | n/a | `any` | n/a | yes |
| vpc\_id | n/a | `any` | n/a | yes |
| vpc\_route\_table\_id | n/a | `any` | n/a | yes |
| websvr\_listen\_ports | n/a | `map(list(number))` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| alias\_dns | n/a |
| instance\_id | n/a |
| private\_dns | n/a |
| private\_ip | n/a |
| public\_dns | n/a |

