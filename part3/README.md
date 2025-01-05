<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_time"></a> [time](#provider\_time) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |
| [aws_appautoscaling_target.ecs_target](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appautoscaling_target) | resource |
| [aws_autoscaling_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) | resource |
| [aws_instance.x86_64](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_lb_listener.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener) | resource |
| [aws_lb_listener_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener_rule) | resource |
| [aws_security_group.example](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [time_sleep.wait_30_seconds](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_ami.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_eks_addon_version.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/eks_addon_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_eks_addon_name"></a> [eks\_addon\_name](#input\_eks\_addon\_name) | n/a | `string` | `"vpc-cni"` | no |
| <a name="input_eks_addon_version"></a> [eks\_addon\_version](#input\_eks\_addon\_version) | n/a | `string` | `"v1.18.1-eksbuild.3"` | no |
| <a name="input_eks_version"></a> [eks\_version](#input\_eks\_version) | n/a | `string` | `"1.30"` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment Name | `string` | n/a | yes |
| <a name="input_lb_info"></a> [lb\_info](#input\_lb\_info) | n/a | `map` | <pre>{<br/>  "name": "test-lb",<br/>  "type": "application"<br/>}</pre> | no |
| <a name="input_lb_type"></a> [lb\_type](#input\_lb\_type) | n/a | `string` | `"application"` | no |
| <a name="input_listener_info"></a> [listener\_info](#input\_listener\_info) | n/a | `map` | <pre>{<br/>  "alpn_policy": "None",<br/>  "port": 443,<br/>  "protocol": "HTTPS",<br/>  "rules": {}<br/>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
