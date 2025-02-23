locals {
  keycloak_saml_idp = aws_iam_saml_provider.keycloak.arn

  user_mapping_info = yamldecode(file("./user_mapping.yaml"))
  aws_roles = {
    for r in local.user_mapping_info["aws_roles"] : r.name => r
  }
  keycloak_groups = {
    for g in local.user_mapping_info["keycloak_groups"] : g.name => g
  }

  tf_desc = "Managed By Terraform"
}

###################################################
# IAM 역할 구성
###################################################
# 키클록 프로바이더를 신뢰하는 정책 검색
data "aws_iam_policy_document" "this" {
  statement {
    actions = ["sts:AssumeRoleWithSAML"]
    principals {
      type        = "Federated"
      identifiers = [local.keycloak_saml_idp]
    }

    condition {
      test     = "ForAnyValue:StringEquals"
      variable = "SAML:aud"
      values   = ["https://signin.aws.amazon.com/saml"]
    }
  }
}

# 키클록 프로바이더를 신뢰하는 AWS IAM 역할 생성
# 키클록 로그인을 위한 역할이라는 것을 명시하기 위해 keycloak-role- 접두사를 붙인다.
resource "aws_iam_role" "this" {
  for_each           = local.aws_roles
  name               = "keycloak-role-${each.value.name}"
  description        = local.tf_desc
  assume_role_policy = data.aws_iam_policy_document.this.json

  tags = merge(
    local.env_tags,
    {
      Name = "keycloak-role-${each.value.name}"
    }
  )
}

# 각 AWS IAM 역할에 연결할 IAM 정책 검색
data "aws_iam_policy" "this" {
  for_each = toset(distinct(flatten([for k, v in local.aws_roles : v.policies])))
  name     = each.value
}

# "{역할}_{권한}" 매핑 정보를 머지된 형태로 반환(9.3절의 유틸리티 모듈 사용)
module "merge_role_policy_attachments" {
  source = "../../modules/chapter9_utility/3_merge_map_in_list"
  input = flatten([
    for k, v in local.aws_roles : {
      for p in v.policies : "${k}_${p}" => {
        name = k, policy = p
      }
    }
  ])
}

# "{역할}_{권한}" 매핑 정보를 통해 역할-권한 연결
resource "aws_iam_role_policy_attachment" "this" {
  for_each   = module.merge_role_policy_attachments.output
  role       = aws_iam_role.this[each.value.name].name
  policy_arn = data.aws_iam_policy.this[each.value.policy].arn
}

###################################################
# 키클록 그룹 구성
###################################################
# 키클록 그룹 생성
resource "keycloak_group" "this" {
  for_each = local.keycloak_groups
  realm_id = local.keycloak_realm_id
  name     = each.value.name

  attributes = merge(
    local.env_tags,
    {
      Name = each.value.name
    }
  )
}

# is_default = true 속성이 있는 그룹인 경우, 디폴트그룹으로 설정
# 디폴트 그룹: 해당 키클록 realm 내에서 사용자가 새로 생성될 때 자동으로 속할 그룹
resource "keycloak_default_groups" "this" {
  realm_id = local.keycloak_realm_id
  group_ids = [
    for k, v in local.keycloak_groups : keycloak_group.this[k].id
    if lookup(v, "is_default", false)
  ]
}

###################################################
# 키클록 역할 구성
###################################################
# AWS IAM 역할과 1대1 관계인 키클록 역할 생성
# 역할 이름은 "{AWS 키클록 SAML 프로바이더 ARN},{AWS IAM 역할 ARN}" 형식이어야 한다.
resource "keycloak_role" "this" {
  for_each    = local.aws_roles
  realm_id    = local.keycloak_realm_id
  client_id   = local.keycloak_aws_client_id
  name        = "${local.keycloak_saml_idp},${aws_iam_role.this[each.key].arn}"
  description = local.tf_desc

  attributes = merge(
    local.env_tags,
    {
      Name = aws_iam_role.this[each.key].name
    }
  )
}

###################################################
# 그룹-역할 매핑
###################################################
# 사용자가 스스로 본인 계정 정보를 확인하고 비밀번호를 변경할 수 있는 키클록 내장 역할 검색
# account 클라이언트의 manage-account 역할의 아이디를 알아내야 한다.
data "keycloak_openid_client" "account" {
  realm_id  = local.keycloak_realm_id
  client_id = "account"
}

data "keycloak_role" "manage_account" {
  realm_id  = local.keycloak_realm_id
  client_id = data.keycloak_openid_client.account.id
  name      = "manage-account"
}

# 키클록 그룹별 각자 사용해야 할 역할들 + manage-account 역할을 연결
resource "keycloak_group_roles" "this" {
  for_each = local.keycloak_groups
  realm_id = local.keycloak_realm_id
  group_id = keycloak_group.this[each.value.name].id

  role_ids = concat([
    for r in each.value.aws_roles : keycloak_role.this[r].id
    ], [
    data.keycloak_role.manage_account.id # account/manage-account 역할
  ])
}
