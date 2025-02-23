locals {
  keycloak_realm_id = "master"
  sso_url_name      = "aws"
  keycloak_base_url = "/realms/${local.keycloak_realm_id}/protocol/saml/clients/${local.sso_url_name}"

  env_tags = {
    tf_env = "part5/chapter17"
  }
}

###################################################
# 키클록: AWS 클라이언트 생성
###################################################
resource "keycloak_saml_client" "aws" {
  realm_id = local.keycloak_realm_id

  client_id                   = "urn:amazon:webservices"
  idp_initiated_sso_url_name  = local.sso_url_name
  assertion_consumer_post_url = "https://signin.aws.amazon.com/saml"

  description = "Managed By Terraform"

  full_scope_allowed = false

  sign_documents          = true
  sign_assertions         = true
  include_authn_statement = true

  signature_algorithm = "RSA_SHA256"
  signature_key_name  = "NONE"

  root_url = "$${authAdminUrl}"
  base_url = local.keycloak_base_url
  valid_redirect_uris = [
    "https://signin.aws.amazon.com/saml",
  ]
}

locals {
  keycloak_aws_client_id = keycloak_saml_client.aws.id
  aws_login_url          = "${local.keycloak_url}${keycloak_saml_client.aws.base_url}"
}

###################################################
# 키클록: 매퍼(Mapper) 생성
###################################################
resource "keycloak_saml_user_attribute_protocol_mapper" "aws_session_name" {
  realm_id      = local.keycloak_realm_id
  client_id     = local.keycloak_aws_client_id
  name          = "Session Name"
  friendly_name = "Session Name"

  user_attribute             = "username"
  saml_attribute_name        = "https://aws.amazon.com/SAML/Attributes/RoleSessionName"
  saml_attribute_name_format = "Basic"
}

resource "keycloak_generic_protocol_mapper" "aws_session_duration" {
  realm_id        = local.keycloak_realm_id
  client_id       = local.keycloak_aws_client_id
  name            = "Session Duration"
  protocol        = "saml"
  protocol_mapper = "saml-hardcode-attribute-mapper"
  config = {
    "attribute.name"       = "https://aws.amazon.com/SAML/Attributes/SessionDuration"
    "attribute.nameformat" = "Basic"
    "attribute.value"      = "28800"
    "friendly.name"        = "Session Duration"
  }
}

resource "keycloak_generic_protocol_mapper" "aws_session_role" {
  realm_id        = local.keycloak_realm_id
  client_id       = local.keycloak_aws_client_id
  name            = "Session Role"
  protocol        = "saml"
  protocol_mapper = "saml-role-list-mapper"
  config = {
    "attribute.name"       = "https://aws.amazon.com/SAML/Attributes/Role"
    "attribute.nameformat" = "Basic"
    "friendly.name"        = "Session Role"
    "single"               = "true"
  }
}

###################################################
# AWS: SAML 프로바이더 생성
###################################################
data "http" "this" {
  url = "${local.keycloak_url}/realms/${local.keycloak_realm_id}/protocol/saml/descriptor"
}

resource "aws_iam_saml_provider" "keycloak" {
  name                   = "keycloak"
  saml_metadata_document = data.http.this.response_body

  tags = merge(
    local.env_tags,
    {
      Name = "keycloak"
    }
  )
}
