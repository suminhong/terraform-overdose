locals {
  eks_addon_info    = var.attribute.eks_addon
  helm_release_info = var.attribute.helm_release

  cluster_info = {
    name     = local.cluster_name
    version  = local.cluster_version
    endpoint = local.cluster_endpoint
    oidc_arn = local.oidc_arn
    oidc_url = local.oidc_url
  }
}

###################################################
# EKS Managed AddOns
###################################################
module "eks_addon" {
  source = "./eks_addon"
  for_each = {
    for k, v in local.eks_addon_info : k => v
    if v.enable
  }

  info_file_path = var.info_file_path

  name         = each.key
  attribute    = each.value
  cluster_info = local.cluster_info
  tags         = local.module_tags

  # coredns가 fargate로 떠야함
  depends_on = [aws_eks_fargate_profile.this]
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

  helm_template_values = {
    vpc_id      = local.vpc_id
    region_name = local.region_name
  }

  depends_on = [
    module.eks_addon,
    module.karpenter_nodes,
    aws_eks_access_entry.node
  ]
}
