<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws.accepter"></a> [aws.accepter](#provider\_aws.accepter) | n/a |
| <a name="provider_aws.requester"></a> [aws.requester](#provider\_aws.requester) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_check_cross"></a> [check\_cross](#module\_check\_cross) | ../utility/9_2_check_aws_cross_provider | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_vpc_peering_connection.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection) | resource |
| [aws_vpc_peering_connection_accepter.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_accepter) | resource |
| [aws_vpc_peering_connection_options.accepter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_options) | resource |
| [aws_vpc_peering_connection_options.requester](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_peering_connection_options) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accepter_vpc"></a> [accepter\_vpc](#input\_accepter\_vpc) | 수락할 VPC 정보 | <pre>object({<br>    vpc_id               = string<br>    vpc_name             = string<br>    allow_dns_resolution = optional(bool, true)<br>  })</pre> | n/a | yes |
| <a name="input_requester_vpc"></a> [requester\_vpc](#input\_requester\_vpc) | 요청할 VPC 정보 | <pre>object({<br>    vpc_id               = string<br>    vpc_name             = string<br>    allow_dns_resolution = optional(bool, true)<br>  })</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | 모든 리소스에 적용될 태그 (map) | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
