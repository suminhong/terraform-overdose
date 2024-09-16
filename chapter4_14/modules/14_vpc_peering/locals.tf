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
  # 서로 다른 프로바이더인지 체크
  is_cross_provider = module.check_cross.is_cross_account || module.check_cross.is_cross_region

  # 피어링 맺을 때 필요한 accepter 프로바이더 정보
  accepter_account_id = module.check_cross.b_account_id
  accepter_region     = module.check_cross.b_region

  # 데이터블록으로 조회한 VPC 정보
  requester_vpc = data.aws_vpc.requester
  accepter_vpc  = data.aws_vpc.accepter

  # 데이터블록으로 조회한 라우팅 테이블들 정보
  requester_rtbs = data.aws_route_tables.requester.ids
  accepter_rtbs  = data.aws_route_tables.accepter.ids

  # 모듈 내 공통 태그
  module_tag = merge(
    var.tags,
    {
      Name          = var.name,
      tf_module     = "14_vpc_peering",
      Requester_VPC = lookup(local.requester_vpc.tags, "Name", "네임태그없음")
      Accepter_VPC  = lookup(local.accepter_vpc.tags, "Name", "네임태그없음")
    }
  )
}
