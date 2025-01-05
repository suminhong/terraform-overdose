<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_keycloak"></a> [keycloak](#requirement\_keycloak) | >= 4.4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |
| <a name="provider_http"></a> [http](#provider\_http) | n/a |
| <a name="provider_keycloak"></a> [keycloak](#provider\_keycloak) | >= 4.4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_merge_role_policy_attachments"></a> [merge\_role\_policy\_attachments](#module\_merge\_role\_policy\_attachments) | ../modules/utility/9_3_merge_map_in_list | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_saml_provider.keycloak](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_saml_provider) | resource |
| [keycloak_default_groups.this](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/default_groups) | resource |
| [keycloak_generic_protocol_mapper.aws_session_duration](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/generic_protocol_mapper) | resource |
| [keycloak_generic_protocol_mapper.aws_session_role](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/generic_protocol_mapper) | resource |
| [keycloak_group.this](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/group) | resource |
| [keycloak_group_roles.this](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/group_roles) | resource |
| [keycloak_role.this](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/role) | resource |
| [keycloak_saml_client.aws](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/saml_client) | resource |
| [keycloak_saml_user_attribute_protocol_mapper.aws_session_name](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/resources/saml_user_attribute_protocol_mapper) | resource |
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [http_http.this](https://registry.terraform.io/providers/hashicorp/http/latest/docs/data-sources/http) | data source |
| [keycloak_openid_client.account](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/data-sources/openid_client) | data source |
| [keycloak_role.manage_account](https://registry.terraform.io/providers/mrparkers/keycloak/latest/docs/data-sources/role) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_login_url"></a> [aws\_login\_url](#output\_aws\_login\_url) | n/a |
<!-- END_TF_DOCS -->
