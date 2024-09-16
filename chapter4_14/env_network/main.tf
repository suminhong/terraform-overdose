locals {
  topology = yamldecode(file("./topology.yaml"))

  # 테라폼 상태 파일 이름의 리스트
  tf_vpc_env_list = distinct(flatten([
    for k, v in local.topology : [v.requester.tf_env, v.accepter.tf_env]
  ]))

  vpc_ids = {
    for k, v in data.terraform_remote_state.vpc : k => v.outputs.vpc_id
  }

  env_tags = {
    tf_env = "chapter4_14/env_network"
  }
}

# VPC ID 정보를 받아오기 위한 원격 상태 불러오기
data "terraform_remote_state" "vpc" {
  for_each = toset(local.tf_vpc_env_list)
  backend  = "s3"
  config = {
    bucket  = "terraform-book-tfstate"
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
    if v.requester.tf_env == "seoul" && v.accepter.tf_env == "virginia"
  }

  providers = {
    aws.requester = aws.seoul
    aws.accepter  = aws.virginia
  }

  name = each.key

  vpc_ids = {
    requester = local.vpc_ids[each.value.requester.tf_env][each.value.requester.vpc]
    accepter  = local.vpc_ids[each.value.accepter.tf_env][each.value.accepter.vpc]
  }

  tags = local.env_tags
}

# Requester가 Seoul 프로바이더고 Accepter가 Seoul 프로바이더인 경우
module "seoul_to_seoul_peering" {
  source = "../modules/14_vpc_peering"
  for_each = {
    for k, v in local.topology : k => v
    if v.requester.tf_env == "seoul" && v.accepter.tf_env == "seoul"
  }

  providers = {
    aws.requester = aws.seoul
    aws.accepter  = aws.seoul
  }

  name = each.key

  vpc_ids = {
    requester = local.vpc_ids[each.value.requester.tf_env][each.value.requester.vpc]
    accepter  = local.vpc_ids[each.value.accepter.tf_env][each.value.accepter.vpc]
  }

  tags = local.env_tags
}
