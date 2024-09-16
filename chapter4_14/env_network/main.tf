locals {
  topology = yamldecode(file("./topology.yaml"))

  tfstate_s3 = "terraform-book-tfstate"
  vpc_env_list = [
    "seoul",
    "virginia"
  ]

  vpc_ids = {
    for k, v in data.terraform_remote_state.vpc : k => v.outputs.vpc_id
  }

  env_tags = {
    tf_env = "chapter4_14/env_network"
  }
}

# VPC 정보를 받아오기 위한 원격 상태 불러오기
data "terraform_remote_state" "vpc" {
  for_each = toset(local.vpc_env_list)
  backend  = "s3"
  config = {
    bucket  = local.tfstate_s3
    key     = "${each.key}.tfstate"
    region  = "ap-northeast-2"
    profile = "terraform"
  }
}

# Requester가 Seoul 프로바이더고 Accepter가 Virginia 프로바이더인 경우
module "seoul_to_virginia_peering" {
  source = "../modules/14_vpc_peering"
  for_each = {
    for k, v in local.topology : k => v
    if v.requester.provider == "seoul" && v.accepter.provider == "virginia"
  }

  providers = {
    aws.requester = aws.seoul
    aws.accepter  = aws.virginia
  }

  name = each.key

  vpc_ids = {
    requester = local.vpc_ids[each.value.requester.provider][each.value.requester.vpc]
    accepter  = local.vpc_ids[each.value.accepter.provider][each.value.accepter.vpc]
  }

  tags = local.env_tags
}

# Requester가 Seoul 프로바이더고 Accepter가 Seoul 프로바이더인 경우
module "seoul_to_seoul_peering" {
  source = "../modules/14_vpc_peering"
  for_each = {
    for k, v in local.topology : k => v
    if v.requester.provider == "seoul" && v.accepter.provider == "seoul"
  }

  providers = {
    aws.requester = aws.seoul
    aws.accepter  = aws.seoul
  }

  name = each.key

  vpc_ids = {
    requester = local.vpc_ids[each.value.requester.provider][each.value.requester.vpc]
    accepter  = local.vpc_ids[each.value.accepter.provider][each.value.accepter.vpc]
  }

  tags = local.env_tags
}
