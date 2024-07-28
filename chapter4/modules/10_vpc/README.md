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
| [aws_cloudwatch_log_group.flowlog](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_db_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_eip.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_elasticache_subnet_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_subnet_group) | resource |
| [aws_flow_log.cw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_flow_log.s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_iam_role.flowlog](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route.private_nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public_igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_s3_bucket.flowlog](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_subnet.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_iam_role.flowlog](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attribute"></a> [attribute](#input\_attribute) | VPC 속성값 정의 | <pre>object({<br>    cidr           = string<br>    env            = optional(string, "develop")<br>    team           = optional(string, "devops")<br>    subnet_newbits = optional(number, 8)<br>    subnet_azs     = list(string)<br>    subnets        = optional(map(list(number)), {})<br>    nat = optional(object({<br>      create = optional(bool, false)<br>      subnet = optional(string, "")<br>      per_az = optional(bool, false)<br>    }), {})<br>    db_subnets = optional(list(string), [])<br>    vpc_flowlogs = optional(object({<br>      cloudwatch = optional(object({<br>        enable = optional(bool, false)<br>        iam_role = optional(object({<br>          create = optional(bool, false)<br>          name   = optional(string, "")<br>        }), {})<br>        retention_in_days = optional(number, 7)<br>        traffic_type      = optional(string, "ALL")<br>      }), {})<br>      s3 = optional(object({<br>        enable = optional(bool, false)<br>        create = optional(bool, false)<br>        bucket = optional(object({<br>          create = optional(bool, false)<br>          name   = optional(string, "")<br>        }), {})<br>        traffic_type = optional(string, "ALL")<br>      }), {})<br>    }), {})<br>  })</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | 구분되는 VPC 이름 | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | 모든 리소스에 적용될 태그 (map) | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
