###################################################
# 수락자 계정의 정보 불러오기
###################################################
module "accepter" {
  source = "../utility/9_1_get_aws_metadata"
  providers = {
    aws = aws.accepter
  }
}

###################################################
# VPC 정보 불러오기
###################################################
data "aws_vpc" "requester" {
  provider = aws.requester
  id       = var.requester_vpc_id
}

data "aws_vpc" "accepter" {
  provider = aws.accepter
  id       = var.accepter_vpc_id
}

###################################################
# 라우팅 테이블 정보 불러오기
###################################################
data "aws_route_tables" "requester" {
  provider = aws.requester
  vpc_id   = var.requester_vpc_id
}

data "aws_route_tables" "accepter" {
  provider = aws.accepter
  vpc_id   = var.accepter_vpc_id
}

###################################################
# 로컬 변수 정의
###################################################
locals {
  # 피어링 맺을 때 필요한 accepter 프로바이더 정보
  accepter_account_id = module.accepter.account_id
  accepter_region     = module.accepter.region_name

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
      Name          = var.name
      tf_module     = "chapter14_vpc_peering"
      Requester_VPC = lookup(local.requester_vpc.tags, "Name", "네임태그없음")
      Accepter_VPC  = lookup(local.accepter_vpc.tags, "Name", "네임태그없음")
    }
  )
}
