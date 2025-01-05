<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 3.0 |
| <a name="provider_aws.seoul"></a> [aws.seoul](#provider\_aws.seoul) | ~> 3.0 |
| <a name="provider_aws.tokyo"></a> [aws.tokyo](#provider\_aws.tokyo) | ~> 3.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_example"></a> [example](#module\_example) | ./example | n/a |
| <a name="module_instances"></a> [instances](#module\_instances) | ./ec2-asg | n/a |
| <a name="module_instances_a"></a> [instances\_a](#module\_instances\_a) | github.com/example-user/terraform-module-ec2-asg | n/a |
| <a name="module_instances_b"></a> [instances\_b](#module\_instances\_b) | github.com/example-user/terraform-module-ec2-asg | n/a |
| <a name="module_my_module"></a> [my\_module](#module\_my\_module) | ./modules/my_module | n/a |
| <a name="module_nested"></a> [nested](#module\_nested) | ./modules/nested-module | n/a |
| <a name="module_vpc"></a> [vpc](#module\_vpc) | terraform-aws-modeuls/vpc/aws | ~> 5.8.1 |

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_instance.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_instance.linux](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_instance.nginx](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_instance.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_instance.windows](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_s3_bucket.bucket_seoul](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.bucket_tokyo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_account_alias.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_account_alias) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | n/a | `string` | n/a | yes |
| <a name="input_bucket_prefix"></a> [bucket\_prefix](#input\_bucket\_prefix) | 버킷의 접두사 | `string` | n/a | yes |
| <a name="input_db_password"></a> [db\_password](#input\_db\_password) | 데이터베이스 비밀번호 | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | n/a | `string` | `"develop"` | no |
| <a name="input_instance_name"></a> [instance\_name](#input\_instance\_name) | modules/nested-module/variables.tf | `string` | n/a | yes |
| <a name="input_is_production"></a> [is\_production](#input\_is\_production) | n/a | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_alias"></a> [account\_alias](#output\_account\_alias) | n/a |
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | n/a |
| <a name="output_available_az"></a> [available\_az](#output\_available\_az) | n/a |
| <a name="output_bucket_arn"></a> [bucket\_arn](#output\_bucket\_arn) | n/a |
| <a name="output_bucket_seoul_id"></a> [bucket\_seoul\_id](#output\_bucket\_seoul\_id) | 서울 버킷의 아이디 |
| <a name="output_bucket_tokyo_id"></a> [bucket\_tokyo\_id](#output\_bucket\_tokyo\_id) | 도쿄 버킷의 아이디 |
| <a name="output_buckets_arns"></a> [buckets\_arns](#output\_buckets\_arns) | n/a |
| <a name="output_instance_id"></a> [instance\_id](#output\_instance\_id) | modules/nested-module/outputs.tf |
| <a name="output_instances_ids"></a> [instances\_ids](#output\_instances\_ids) | output.tf |
| <a name="output_region_name"></a> [region\_name](#output\_region\_name) | n/a |
<!-- END_TF_DOCS -->
