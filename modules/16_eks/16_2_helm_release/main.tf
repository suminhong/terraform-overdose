locals {
  # 기본 설정값 디렉터리
  helm_default_values_path = "${path.root}/info_files/helm_default_values"
  helm_chart_info          = yamldecode(file("${local.helm_default_values_path}/_helm_charts.yaml"))[var.name]

  chart_repo    = coalesce(var.attribute.repository, local.helm_chart_info.repository)
  chart_version = coalesce(var.attribute.version, local.helm_chart_info.version)
  namespace     = coalesce(var.attribute.namespace, local.helm_chart_info.namespace)

  irsa_policies_path = "${path.root}/info_files/irsa_policies"
  irsa_policies_set = [
    for p in fileset(local.irsa_policies_path, "*.json") : trimsuffix(p, ".json")
  ]

  # irsa_policies/ 디렉터리에 차트 이름과 동일한 JSON 파일이 존재하는 경우
  create_irsa = contains(local.irsa_policies_set, var.name)
}

# IAM 역할 생성
resource "aws_iam_role" "this" {
  count = local.create_irsa ? 1 : 0

  name = "${var.cluster_name}-${var.name}"
  assume_role_policy = templatefile("${path.module}/irsa_assume_role_template.json", {
    oidc_arn  = var.cluster_oidc.arn
    oidc_url  = var.cluster_oidc.url
    namespace = local.namespace
  })
}

# IAM 역할에 인라인 정책 생성
resource "aws_iam_role_policy" "this" {
  count = local.create_irsa ? 1 : 0

  name   = var.name
  role   = aws_iam_role.this[count.index].id
  policy = file("${local.irsa_policies_path}/${var.name}.json")
}

locals {
  helm_default_values = templatefile("${local.helm_default_values_path}/${var.name}.yaml", {
    irsa_arn = try(aws_iam_role.this[0].arn, "")
  })

  helm_overwrite_values = lookup(var.attribute, "overwrite_values", {})
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
