locals {
  irsa_assume_role_templatefile = "${path.module}/irsa_assume_role_template.json"

  irsa_policies_path = "${var.info_file_path}/irsa_policies"
  irsa_policies_set = [
    for p in fileset(local.irsa_policies_path, "*.json") : trimsuffix(p, ".json")
  ]

  # irsa_policies/ 밑에 차트 이름과 동일한 json file이 존재하는 경우.
  create_irsa = contains(local.irsa_policies_set, var.app_name)

  module_tags = merge(
    var.tags,
    {
      tf_module = "${lookup(var.tags, "tf_module", "")}/create_irsa"
    }
  )
}

###################################################
# create_irsa = true인 경우, IRSA용 IAM Role 생성
###################################################
## IAM Role 생성
resource "aws_iam_role" "this" {
  count = local.create_irsa ? 1 : 0

  name        = "${var.cluster_name}-${var.app_name}"
  description = "Managed By Terraform"

  assume_role_policy = templatefile(local.irsa_assume_role_templatefile, {
    oidc_arn  = var.oidc_arn
    oidc_url  = var.oidc_url
    namespace = var.namespace
  })

  tags = local.module_tags
}

## IAM Role에 인라인정책 생성
resource "aws_iam_role_policy" "this" {
  count = local.create_irsa ? 1 : 0

  name = var.app_name
  role = aws_iam_role.this[count.index].id
  policy = templatefile("${local.irsa_policies_path}/${var.app_name}.json", {
    cluster_name = var.cluster_name
  })
}

###################################################
# IRSA용 IAM Role의 ARN 출력
###################################################
output "role_arn" {
  value = try(aws_iam_role.this[0].arn, "")
}
