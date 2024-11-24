<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_name"></a> [app\_name](#input\_app\_name) | IRSA가 필요한 Application 이름 | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | EKS 클러스터 이름 | `string` | n/a | yes |
| <a name="input_info_file_path"></a> [info\_file\_path](#input\_info\_file\_path) | Info 파일들이 들어있는 경로 | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | IRSA를 사용할 Application이 설치될 네임스페이스 | `string` | n/a | yes |
| <a name="input_oidc_arn"></a> [oidc\_arn](#input\_oidc\_arn) | OIDC 프로바이더 ARN | `string` | n/a | yes |
| <a name="input_oidc_url"></a> [oidc\_url](#input\_oidc\_url) | OIDC 프로바이더 URL | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | ################################################## IRSA용 IAM Role의 ARN 출력 ################################################## |
<!-- END_TF_DOCS -->
