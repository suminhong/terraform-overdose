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
| <a name="module_current"></a> [current](#module\_current) | ../utility/9_1_get_aws_metadata | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_eip.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route.private_nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public_igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attribute"></a> [attribute](#input\_attribute) | VPC 속성값 정의 | <pre>object({<br>    cidr           = string<br>    env            = optional(string, "develop")<br>    team           = optional(string, "devops")<br>    subnet_newbits = optional(number, 8)<br>    subnet_azs     = list(string)<br>    subnets        = optional(map(list(number)), {})<br>    nat = optional(object({<br>      create = optional(bool, false)<br>      subnet = optional(string, "")<br>      per_az = optional(bool, false)<br>    }), {})<br>  })</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | 구분되는 VPC 이름 | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | 모든 리소스에 적용될 태그 (map) | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_igw_id"></a> [igw\_id](#output\_igw\_id) | 인터넷 게이트웨이 ID |
| <a name="output_nat_ids"></a> [nat\_ids](#output\_nat\_ids) | AZ별 나트 게이트웨이 ID 맵 |
| <a name="output_private_rt_ids"></a> [private\_rt\_ids](#output\_private\_rt\_ids) | AZ별 프라이빗 라우팅 테이블 ID 맵 |
| <a name="output_public_rt_id"></a> [public\_rt\_id](#output\_public\_rt\_id) | 퍼블릭 라우팅 테이블 ID |
| <a name="output_subnet_ids"></a> [subnet\_ids](#output\_subnet\_ids) | 서브넷 이름별 ID 리스트 |
| <a name="output_subnet_ids_with_az"></a> [subnet\_ids\_with\_az](#output\_subnet\_ids\_with\_az) | 서브넷 이름별/AZ별 ID 맵 |
| <a name="output_vpc_cidr"></a> [vpc\_cidr](#output\_vpc\_cidr) | VPC CIDR |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | VPC ID |
| <a name="output_vpc_name"></a> [vpc\_name](#output\_vpc\_name) | VPC 이름 |
<!-- END_TF_DOCS -->
