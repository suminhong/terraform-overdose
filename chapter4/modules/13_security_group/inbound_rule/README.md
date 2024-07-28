<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_http"></a> [http](#provider\_http) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_security_group_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [http_http.myip](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_rule_set"></a> [rule\_set](#input\_rule\_set) | 보안 그룹 인바운드 Rule Set | <pre>set(object({<br>    desc      = string<br>    protocol  = string<br>    from_port = number<br>    to_port   = number<br>    source    = any<br>  }))</pre> | n/a | yes |
| <a name="input_sg_id"></a> [sg\_id](#input\_sg\_id) | 보안 그룹 ID | `string` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | 보안 그룹이 존재하는 VPC의 CIDR | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
