locals {
  cluster_name    = var.cluster_info.name
  cluster_version = var.cluster_info.version

  module_tags = merge(
    var.tags,
    {
      tf_module = "${lookup(var.tags, "tf_module", "")}/eks_addon"
    }
  )
}

###################################################
# IRSA 롤 생성
###################################################
module "irsa" {
  source = "../create_irsa"

  info_file_path = var.info_file_path

  cluster_name = local.cluster_name
  app_name     = var.name
  namespace    = "kube-system"
  oidc_arn     = var.cluster_info.oidc_arn
  oidc_url     = var.cluster_info.oidc_url

  tags = local.module_tags
}

###################################################
# EKS Managed Add-On 생성
###################################################
data "aws_eks_addon_version" "this" {
  addon_name         = var.name
  kubernetes_version = local.cluster_version
}

locals {
  # version 값이 ""(default)인 경우 권장 버전을 자동으로 사용 (코드에 추가로 적용해두는것을 권장)
  addon_default_version = data.aws_eks_addon_version.this.version
  addon_version         = var.attribute.version != "" ? var.attribute.version : local.addon_default_version

  # 추가 Configuration Values 설정
  configuration        = var.attribute.configuration
  configuration_values = local.configuration == "" ? null : jsonencode(yamldecode(local.configuration))
}

resource "aws_eks_addon" "this" {
  cluster_name                = local.cluster_name
  addon_name                  = var.name
  addon_version               = local.addon_version
  service_account_role_arn    = module.irsa.role_arn != "" ? module.irsa.role_arn : null
  resolve_conflicts_on_update = "PRESERVE"
  configuration_values        = local.configuration_values
  tags = merge(
    local.module_tags,
    {
      Name = "${local.cluster_name}-${var.name}"
    }
  )
}
