locals {
  info_files = "${path.root}/../info_files"

  vpc_set = toset([
    for vpcfile in fileset(local.info_files, "*/vpc.yaml") : dirname(vpcfile)
  ])

  vpc_info_map = {
    for k in local.vpc_set : k => yamldecode(file("${local.info_files}/${k}/vpc.yaml"))
  }

  env_tags = {
    tf_env = "chapter4/env"
  }
}

###################################################
# Create VPC
###################################################
module "vpc" {
  for_each = local.vpc_set
  source   = "../modules/11_vpc"

  name      = each.key
  attribute = local.vpc_info_map[each.key]

  tags = local.env_tags
}

###################################################
# Create Security Groups
###################################################
module "sg" {
  for_each = local.vpc_set
  source   = "../modules/12_security_group"

  vpc_name = each.key
  vpc_id   = module.vpc[each.key].vpc_id

  sg_set = {
    for sgfile in fileset(local.info_files, "${each.key}/sg/*.csv") :
    trimsuffix(basename(sgfile), ".csv") => csvdecode(file("${local.info_files}/${sgfile}"))
  }

  tags = local.env_tags
}

###################################################
# Create EC2 Servers
###################################################
module "ec2" {
  for_each = local.vpc_set
  source   = "../modules/13_ec2"

  vpc_name = each.key
  vpc_id   = module.vpc[each.key].vpc_id

  subnet_id_map = module.vpc[each.key].subnet_ids_with_az
  sg_id_map     = module.sg[each.value].sg_id

  ec2_set = {
    for ec2file in fileset(local.info_files, "${each.key}/ec2/*.yaml") :
    trimsuffix(basename(ec2file), ".yaml") => yamldecode(file("${local.info_files}/${ec2file}"))
  }

  tags = local.env_tags
}

###################################################
# Create VPC Peering
###################################################
module "vpc_peering" {
  source = "../modules/14_vpc_peering"
  providers = {
    aws.requester = aws
    aws.accepter  = aws
  }

  requester_vpc = {
    vpc_id   = module.vpc["production"].vpc_id
    vpc_name = module.vpc["production"].vpc_name
  }

  accepter_vpc = {
    vpc_id   = module.vpc["develop"].vpc_id
    vpc_name = module.vpc["develop"].vpc_name
  }
}
