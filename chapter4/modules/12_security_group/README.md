<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_inbound_rule"></a> [inbound\_rule](#module\_inbound\_rule) | ./inbound_rule | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_sg_set"></a> [sg\_set](#input\_sg\_set) | 보안 그룹별 인바운드 Rule Set | <pre>map(set(object({<br>    desc      = optional(string, "")<br>    protocol  = string<br>    from_port = number<br>    to_port   = number<br>    source    = string<br>  })))</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | 모든 리소스에 적용될 태그 (map) | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | 보안 그룹이 존재할 VPC의 ID | `string` | n/a | yes |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | 보안 그룹이 존재할 VPC의 이름 | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_sg_id"></a> [sg\_id](#output\_sg\_id) | 보안 그룹 ID 맵 |
<!-- END_TF_DOCS -->
