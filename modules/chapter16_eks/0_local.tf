data "aws_region" "current" {}

locals {
  region_name = data.aws_region.current.name

  # /common.yaml 해독하여 사용
  common_vars = yamldecode(file("${path.module}/../../common.yaml"))

  ## Input to EKS Cluster Resources
  env = var.attribute.env

  input_cluster_info = var.attribute.cluster_info
  network_info       = var.attribute.network_info

  cluster_name    = local.input_cluster_info.name
  cluster_version = local.input_cluster_info.version

  log_types      = local.input_cluster_info.log_types
  auth_mode      = local.input_cluster_info.auth_mode
  upgrade_policy = local.input_cluster_info.upgrade_policy

  vpc_id   = var.vpc_info.vpc_id
  vpc_name = local.network_info.vpc_name

  subnet_ids_map = var.vpc_info.subnet_ids
  subnet_ids = toset(flatten([
    for s in local.network_info.subnet_name_list : local.subnet_ids_map[s]
  ]))

  tf_desc = local.common_vars.tf_desc

  k8s_labels = {
    "app.terraform-book/managed-by" = "Terraform"
    "app.terraform-book/tf-module"  = "eks"
  }

  module_tags = merge(
    var.tags,
    {
      tf_module   = "chapter16_eks"
      EKS_Cluster = local.cluster_name
      Env         = local.env
    }
  )

  ## Output to EKS Cluster Resources
  cluster_info = {
    name     = local.cluster_name
    version  = local.cluster_version
    endpoint = local.cluster_endpoint
    oidc_arn = local.oidc_arn
    oidc_url = local.oidc_url
  }

  ## validation (precondition) 을 위해 선언해두는 사용 가능한 변수값들
  allow_log_type = [
    "api", "audit", "authenticator", "controllerManager", "scheduler"
  ]
  allow_auth_mode = [
    "API", "API_AND_CONFIG_MAP", "CONFIG_MAP"
  ]
  allow_upgrade_policy = [
    "EXTENDED", "STANDARD"
  ]
  allow_access_entry_policy_name = [
    "AmazonEKSAdminPolicy",
    "AmazonEKSClusterAdminPolicy",
    "AmazonEKSAdminViewPolicy",
    "AmazonEKSEditPolicy",
    "AmazonEKSViewPolicy"
  ]
  allow_access_entry_policy_type = [
    "cluster", "namespace"
  ]
}
