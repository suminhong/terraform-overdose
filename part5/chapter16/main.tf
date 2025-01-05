locals {
  env_tags = {
    tf_env = "part5/chapter16"
  }

  info_files = "${path.root}/info_files"

  vpc_files = "${local.info_files}/vpc"
  eks_files = "${local.info_files}/cluster_values"

  cluster1_yaml = yamldecode(file("${local.eks_files}/cluster1.yaml"))
}

###################################################
# Create VPC
###################################################
module "vpc" {
  for_each = toset([
    for vpcfile in fileset(local.vpc_files, "*.yaml") : trimsuffix(basename(vpcfile), ".yaml")
  ])
  source = "../../modules/chapter11_vpc"

  name      = each.key
  attribute = yamldecode(file("${local.vpc_files}/${each.key}.yaml"))

  tags = local.env_tags
}

###################################################
# Create EKS : cluster1
###################################################
module "eks_cluster1" {
  source = "../../modules/chapter16_eks"
  vpc_info = {
    vpc_id     = module.vpc[local.cluster1_yaml.network_info.vpc_name].vpc_id
    subnet_ids = module.vpc[local.cluster1_yaml.network_info.vpc_name].subnet_ids
  }

  attribute      = local.cluster1_yaml
  info_file_path = local.info_files

  tags = local.env_tags
}
