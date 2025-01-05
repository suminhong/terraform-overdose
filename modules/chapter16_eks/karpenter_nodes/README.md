<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 2.0.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | >= 2.0.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubectl_manifest.node_class](https://registry.terraform.io/providers/alekc/kubectl/latest/docs/resources/manifest) | resource |
| [kubectl_manifest.node_pool](https://registry.terraform.io/providers/alekc/kubectl/latest/docs/resources/manifest) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attribute"></a> [attribute](#input\_attribute) | 카펜터 노드 정보 | `any` | n/a | yes |
| <a name="input_k8s_labels"></a> [k8s\_labels](#input\_k8s\_labels) | A map of labels to add to all k8s resources | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | 카펜터 노드 이름 | `string` | n/a | yes |
| <a name="input_node_role"></a> [node\_role](#input\_node\_role) | 카펜터 노드가 사용할 IAM Role Instance Profile | `string` | n/a | yes |
| <a name="input_node_sg"></a> [node\_sg](#input\_node\_sg) | 카펜터 노드가 사용할 보안 그룹 id | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | 카펜터 노드가 위치할 서브넷 id list | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
