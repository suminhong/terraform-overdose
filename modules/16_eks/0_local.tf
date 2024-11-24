data "aws_region" "current" {}

locals {
  region_name = data.aws_region.current.name

  # /common.yaml 해독하여 사용
  common_vars = yamldecode(file("${path.module}/../../common.yaml"))

  ## Input to EKS Cluster Resource
  env = var.attribute.env

  input_cluster_info = var.attribute.cluster_info
  network_info       = var.attribute.network_info

  cluster_name    = local.input_cluster_info.name
  cluster_version = local.input_cluster_info.version

  vpc_id   = var.vpc_info.vpc_id
  vpc_name = local.network_info.vpc_name

  subnet_ids_map = var.vpc_info.subnet_ids
  subnet_ids = toset(flatten([
    for s in local.network_info.subnet_name_list : local.subnet_ids_map[s]
  ]))

  tf_desc = local.common_vars.tf_desc
  module_tags = merge(
    var.tags,
    {
      tf_module   = "16_eks"
      EKS_Cluster = local.cluster_name
      Env         = local.env
    }
  )

  k8s_labels = {
    "app.terraform-book/managed-by" = "Terraform"
    "app.terraform-book/tf-module"  = "eks"
  }
}
