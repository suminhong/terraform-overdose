# 입력받은 두 프로바이더가 동일한지 체크
module "check_cross" {
  source = "../utility/9_2_check_aws_cross_provider"
  providers = {
    aws.a = aws.requester
    aws.b = aws.accepter
  }
}

# VPC 정보 불러오기
data "aws_vpc" "requester" {
  provider = aws.requester
  id       = var.vpc_ids.requester
}

data "aws_vpc" "accepter" {
  provider = aws.accepter
  id       = var.vpc_ids.accepter
}

# 라우팅 테이블 정보 불러오기
data "aws_route_tables" "requester" {
  provider = aws.requester
  vpc_id   = var.vpc_ids.requester
}

data "aws_route_tables" "accepter" {
  provider = aws.accepter
  vpc_id   = var.vpc_ids.accepter
}

# 로컬 변수 정의
locals {
  is_cross_account = module.check_cross.is_cross_account
  is_cross_region  = module.check_cross.is_cross_region

  need_accepter = local.is_cross_account || local.is_cross_region

  accepter_account_id = module.check_cross.b_account_id
  accepter_region     = module.check_cross.b_region

  name = var.name

  requester_vpc = data.aws_vpc.requester
  accepter_vpc  = data.aws_vpc.accepter

  requester_rtbs = data.aws_route_tables.requester.ids
  accepter_rtbs  = data.aws_route_tables.accepter.ids

  module_tag = merge(
    var.tags,
    {
      Name          = local.name,
      tf_module     = "14_vpc_peering",
      Requester_VPC = lookup(local.requester_vpc.tags, "Name", "네임태그없음")
      Accepter_VPC  = lookup(local.accepter_vpc.tags, "Name", "네임태그없음")
    }
  )
}
