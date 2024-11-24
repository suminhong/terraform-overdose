<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_irsa"></a> [irsa](#module\_irsa) | ../create_irsa | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_eks_addon.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_addon) | resource |
| [aws_eks_addon_version.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_addon_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attribute"></a> [attribute](#input\_attribute) | EKS Addon 속성 | `any` | n/a | yes |
| <a name="input_cluster_info"></a> [cluster\_info](#input\_cluster\_info) | 클러스터 정보 | <pre>object({<br/>    name     = string<br/>    version  = string<br/>    endpoint = string<br/>    oidc_arn = string<br/>    oidc_url = string<br/>  })</pre> | n/a | yes |
| <a name="input_info_file_path"></a> [info\_file\_path](#input\_info\_file\_path) | Info 파일들이 들어있는 경로 | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | EKS Addon 이름 | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
