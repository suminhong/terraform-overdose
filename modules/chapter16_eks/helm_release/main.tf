locals {
  cluster_name = var.cluster_info.name

  helm_default_values_path = "${var.info_file_path}/helm_default_values"
  helm_chart_info          = yamldecode(file("${local.helm_default_values_path}/_helm_charts.yaml"))[var.name]

  chart_repo    = coalesce(var.attribute.repository, local.helm_chart_info.repository)
  chart_version = coalesce(var.attribute.version, local.helm_chart_info.version)
  namespace     = coalesce(var.attribute.namespace, local.helm_chart_info.namespace)

  module_tags = merge(
    var.tags,
    {
      tf_module = "${lookup(var.tags, "tf_module", "")}/helm_release"
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
  namespace    = local.namespace
  oidc_arn     = var.cluster_info.oidc_arn
  oidc_url     = var.cluster_info.oidc_url

  tags = local.module_tags
}

###################################################
# 헬름 차트 배포
###################################################
locals {
  helm_template_values = merge(
    var.helm_template_values, {
      cluster_id   = local.cluster_name
      cluster_name = local.cluster_name
      irsa_arn     = module.irsa.role_arn
    }
  )

  helm_default_values   = templatefile("${local.helm_default_values_path}/${var.name}.yaml", local.helm_template_values)
  helm_overwrite_values = var.attribute.overwrite_values
}

resource "helm_release" "this" {
  name       = var.name
  repository = local.chart_repo
  chart      = var.name
  version    = local.chart_version
  namespace  = local.namespace
  timeout    = "1200"

  # 기본값
  values = [
    local.helm_default_values
  ]

  # overwrite
  dynamic "set" {
    for_each = local.helm_overwrite_values
    content {
      name  = set.key
      value = set.value
    }
  }
}
