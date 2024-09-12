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
| <a name="module_merge_ec2_volume_set"></a> [merge\_ec2\_volume\_set](#module\_merge\_ec2\_volume\_set) | ../utility/9_3_merge_map_in_list | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ebs_volume.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) | resource |
| [aws_eip.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_volume_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [aws_ami.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_ec2_set"></a> [ec2\_set](#input\_ec2\_set) | 보안 그룹 ID 맵 데이터 | <pre>map(object({<br>    # required<br>    env             = string<br>    team            = string<br>    service         = string<br>    subnet          = string<br>    az              = string<br>    security_groups = list(string)<br>    ami_id          = string<br>    instance_type   = string<br>    root_volume = object({<br>      size = number<br>      type = optional(string, "gp3")<br>    })<br>    # optional<br>    ec2_key    = optional(string)<br>    ec2_role   = optional(string)<br>    private_ip = optional(string)<br>    additional_volumes = optional(set(object({<br>      device = string<br>      size   = number<br>      type   = optional(string, "gp3")<br>      iops   = optional(number, 3000)<br>    })), [])<br>  }))</pre> | n/a | yes |
| <a name="input_sg_id_map"></a> [sg\_id\_map](#input\_sg\_id\_map) | 보안 그룹 ID 맵 데이터 | `map(string)` | n/a | yes |
| <a name="input_subnet_id_map"></a> [subnet\_id\_map](#input\_subnet\_id\_map) | 서브넷 ID 맵 데이터 | `map(map(string))` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | 모든 리소스에 적용될 태그 (map) | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | EC2가 존재할 VPC의 ID | `string` | n/a | yes |
| <a name="input_vpc_name"></a> [vpc\_name](#input\_vpc\_name) | EC2가 존재할 VPC의 이름 | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
