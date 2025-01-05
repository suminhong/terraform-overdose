locals {
  helm_release_info = var.attribute.helm_release
}

###################################################
# Helm Applications
###################################################
module "helm_release" {
  source = "./helm_release"
  for_each = {
    for k, v in local.helm_release_info : k => v
    if v.enable
  }

  info_file_path = var.info_file_path

  name         = each.key
  attribute    = each.value
  cluster_info = local.cluster_info
  tags         = local.module_tags

  depends_on = [
    module.eks_addon,
    module.karpenter_nodes
  ]
}

###################################################
# [코드 16-22 ~ 16-29]
# 예제용 코드
###################################################
# module "helm_release" {
#   source = "./16_2_helm_release"
#   for_each = {
#     for k, v in local.helm_release_info : k => v
#     if v.enable
#   }

#   name      = each.key
#   attribute = each.value

#   cluster_name = local.cluster_name
#   cluster_oidc = {
#     # OIDC 프로바이더 자원 전달
#     arn = aws_iam_openid_connect_provider.this.arn
#     url = aws_iam_openid_connect_provider.this.url
#   }
# }
