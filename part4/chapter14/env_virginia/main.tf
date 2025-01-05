locals {
  info_files = "${path.root}/info_files"

  vpc_set = toset([
    for vpcfile in fileset(local.info_files, "*/vpc.yaml") : dirname(vpcfile)
  ])

  vpc_info_map = {
    for k in local.vpc_set : k => yamldecode(file("${local.info_files}/${k}/vpc.yaml"))
  }

  env_tags = {
    tf_env = "part4/chapter14/env_virginia"
  }
}

###################################################
# Create VPC
###################################################
module "vpc" {
  for_each = local.vpc_set
  source   = "../../../modules/chapter11_vpc"

  name      = each.key
  attribute = local.vpc_info_map[each.key]

  tags = local.env_tags
}
