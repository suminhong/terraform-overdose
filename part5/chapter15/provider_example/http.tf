# 코드 15-2
data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}

locals {
  public_ip = chomp(data.http.myip.response_body)
}

# 코드 15-3
locals {
  keycloak_url   = "https://keycloak.terraform.io"
  keycloak_realm = "aws"


  keycloak_saml_descriptor_url = "${local.keycloak_url}/realms/${local.keycloak_realm}/protocol/saml/descriptor"
}

data "http" "this" {
  url = local.keycloak_saml_descriptor_url
}

resource "aws_iam_saml_provider" "this" {
  name                   = "keycloak"
  saml_metadata_document = data.http.this.response_body
}
