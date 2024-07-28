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
| <a name="input_vpc_info"></a> [vpc\_info](#input\_vpc\_info) | 보안 그룹이 존재할 VPC의 이름과 ID | <pre>object({<br>    name = string<br>    id   = string<br>  })</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
