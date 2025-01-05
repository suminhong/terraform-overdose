# 모듈 호출 후 사용
module "check_cross" {
  source = "../modules/chapter9_utility/2_check_aws_cross_provider"
  providers = {
    aws.a = aws.requester
    aws.b = aws.accepter
  }
}


locals {
  is_cross_account = module.check_cross.is_cross_account
  is_cross_region  = module.check_cross.is_cross_region


  need_accepter = local.is_cross_account || local.is_cross_region
}


# VPC Peering 생성
resource "aws_vpc_peering_connection" "this" {
  peer_owner_id = local.is_cross_account ? local.accepter_account : null
  peer_region   = local.is_cross_region ? local.accepter_region : null

  auto_accept = local.need_accepter ? false : true

  dynamic "requester" {
    for_each = local.need_accepter ? toset([]) : toset(["1"])
    content {
      allow_remote_vpc_dns_resolution = true
    }
  }

  dynamic "accepter" {
    for_each = local.need_accepter ? toset([]) : toset(["1"])
    content {
      allow_remote_vpc_dns_resolution = true
    }
  }
  # ...
}
