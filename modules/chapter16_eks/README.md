<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 2.0.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | n/a |
| <a name="provider_tls"></a> [tls](#provider\_tls) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks_addon"></a> [eks\_addon](#module\_eks\_addon) | ./eks_addon | n/a |
| <a name="module_helm_release"></a> [helm\_release](#module\_helm\_release) | ./helm_release | n/a |
| <a name="module_karpenter_nodes"></a> [karpenter\_nodes](#module\_karpenter\_nodes) | ./karpenter_nodes | n/a |
| <a name="module_karpenter_release"></a> [karpenter\_release](#module\_karpenter\_release) | ./helm_release | n/a |
| <a name="module_merge_access_entry_policy_association"></a> [merge\_access\_entry\_policy\_association](#module\_merge\_access\_entry\_policy\_association) | ../chapter9_utility/3_merge_map_in_list | n/a |
| <a name="module_sg"></a> [sg](#module\_sg) | ../chapter12_security_group | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.karpenter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.karpenter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_eks_access_entry.nodes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_entry) | resource |
| [aws_eks_access_entry.standard](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_entry) | resource |
| [aws_eks_access_policy_association.standard](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_access_policy_association) | resource |
| [aws_eks_cluster.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster) | resource |
| [aws_eks_fargate_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_fargate_profile) | resource |
| [aws_iam_instance_profile.node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_openid_connect_provider.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kms_alias.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_security_group_rule.cluster_to_node](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.node_to_cluster](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_sqs_queue.karpenter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_sqs_queue_policy.karpenter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue_policy) | resource |
| [kubernetes_annotations.sc_gp2](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/annotations) | resource |
| [kubernetes_deployment_v1.overprovisioning](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/deployment_v1) | resource |
| [kubernetes_priority_class_v1.overprovisioning](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/priority_class_v1) | resource |
| [kubernetes_storage_class_v1.gp3](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/storage_class_v1) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_eks_cluster_auth.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_cluster_auth) | data source |
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy_document.karpenter_sqs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_session_context.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_session_context) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [tls_certificate.this](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_attribute"></a> [attribute](#input\_attribute) | EKS Cluster를 만들기 위한 정보 | <pre>object({<br/>    env = string<br/>    cluster_info = object({<br/>      name            = string<br/>      version         = string<br/>      log_types       = list(string)<br/>      auth_mode       = optional(string, "API_AND_CONFIG_MAP")<br/>      upgrade_policy  = optional(string, "EXTENDED")<br/>      arc_zonal_shift = optional(bool, false)<br/>    })<br/>    network_info = object({<br/>      vpc_name             = string<br/>      subnet_name_list     = list(string)<br/>      allow_public_access  = optional(bool, false)<br/>      allow_private_access = optional(bool, true)<br/>      public_access_cidrs  = optional(list(string), ["0.0.0.0/0"])<br/>      private_access_cidrs = optional(list(string), [])<br/>    })<br/>    access_entries = optional(list(object({<br/>      principal_arn = string<br/>      k8s_groups    = optional(list(string))<br/>      k8s_username  = optional(string)<br/>      access_policies = optional(list(object({<br/>        policy     = string<br/>        type       = string<br/>        namespaces = optional(list(string), [])<br/>      })), [])<br/>    })), [])<br/>    fargate_profile = optional(object({<br/>      subnet_name_list = optional(list(string), [])<br/>      profiles = optional(list(object({<br/>        name      = string<br/>        namespace = string<br/>        labels    = map(string)<br/>      })), [])<br/>    }), {})<br/>    eks_addon = optional(map(object({<br/>      enable        = bool<br/>      version       = optional(string, "")<br/>      configuration = optional(string, "")<br/>    })), {})<br/>    helm_release = optional(map(object({<br/>      enable           = bool<br/>      repository       = optional(string, "")<br/>      version          = optional(string, "")<br/>      namespace        = optional(string, "")<br/>      overwrite_values = optional(map(string), {})<br/>    })), {})<br/>    karpenter = optional(map(object({<br/>      subnet_name_list = list(string)<br/>      volume_size_list = list(number)<br/>      node_spec = object({<br/>        expireAfter       = string<br/>        imgae_alias       = list(string)<br/>        image_arch        = list(string)<br/>        image_os          = list(string)<br/>        instance_capacity = list(string)<br/>        instance_family   = list(string)<br/>        instance_size     = list(string)<br/>      })<br/>      disruption = object({<br/>        consolidationPolicy = string<br/>        consolidateAfter    = string<br/>        budgets = optional(list(object({<br/>          nodes    = optional(string)<br/>          schedule = optional(string)<br/>          duration = optional(string)<br/>          reasons  = optional(list(string))<br/>        })), [])<br/>      })<br/>      taints     = optional(map(string), {})<br/>      k8s_labels = optional(map(string), {})<br/>    })), {})<br/>  })</pre> | n/a | yes |
| <a name="input_info_file_path"></a> [info\_file\_path](#input\_info\_file\_path) | Info 파일들이 들어있는 경로 | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to add to all resources | `map(string)` | `{}` | no |
| <a name="input_vpc_info"></a> [vpc\_info](#input\_vpc\_info) | VPC id & subnet ids | <pre>object({<br/>    vpc_id     = string<br/>    subnet_ids = map(list(string))<br/>  })</pre> | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
