<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_irsa"></a> [irsa](#module\_irsa) | ../create_irsa | n/a |

## Resources

| Name | Type |
|------|------|
| [helm_release.this](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attribute"></a> [attribute](#input\_attribute) | 클러스터별 명세 파일에 명세된 애플리케이션별 속성값 | `map` | <pre>{<br/>  "enable": true,<br/>  "namespace": "",<br/>  "overwrite_values": {},<br/>  "repository": "",<br/>  "version": ""<br/>}</pre> | no |
| <a name="input_cluster_info"></a> [cluster\_info](#input\_cluster\_info) | 클러스터 정보 | <pre>object({<br/>    name     = string<br/>    version  = string<br/>    endpoint = string<br/>    oidc_arn = string<br/>    oidc_url = string<br/>  })</pre> | n/a | yes |
| <a name="input_helm_template_values"></a> [helm\_template\_values](#input\_helm\_template\_values) | Helm Value 파일 해독 시 필요한 값들 정의 | `map(string)` | `{}` | no |
| <a name="input_info_file_path"></a> [info\_file\_path](#input\_info\_file\_path) | Info 파일들이 들어있는 경로 | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | 헬름 차트 이름 (애플리케이션 이름) | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
