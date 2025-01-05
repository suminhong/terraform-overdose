variable "eks_version" {
  default = "1.30"
}

variable "eks_addon_name" {
  default = "vpc-cni"
}

variable "eks_addon_version" {
  default = "v1.18.1-eksbuild.3"
}

data "aws_eks_addon_version" "this" {
  addon_name         = var.eks_addon_name
  kubernetes_version = var.eks_version
}

locals {
  addon_default_version = data.aws_eks_addon_version.this.version
}

check "addon_versions" {
  ## 현재 Default Version과 달라지는 경우 WARNING 문구 발생
  assert {
    condition     = local.addon_default_version == var.eks_addon_version
    error_message = "EKS ${var.eks_version}에서 ${upper(var.eks_addon_name)}의 현재 권장 버전은 ${local.addon_default_version} 입니다."
  }
}
