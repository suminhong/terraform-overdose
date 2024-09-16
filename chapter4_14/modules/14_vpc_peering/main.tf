###################################################
# VPC Peering Connection
###################################################
resource "aws_vpc_peering_connection" "this" {
  provider = aws.requester

  peer_owner_id = local.is_cross_account ? local.accepter_account_id : null
  peer_region   = local.is_cross_region ? local.accepter_region : null

  peer_vpc_id = local.accepter_vpc.id
  vpc_id      = local.requester_vpc.id

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

  tags = merge(
    local.module_tag,
    {
      Side = "Requester"
    }
  )
}

locals {
  peering_id = aws_vpc_peering_connection.this.id
}

###################################################
# VPC Peering Accepter (서로 다른 프로바이더인 경우)
###################################################
resource "aws_vpc_peering_connection_accepter" "this" {
  count                     = local.need_accepter ? 1 : 0
  provider                  = aws.accepter
  vpc_peering_connection_id = local.peering_id
  auto_accept               = true

  tags = merge(
    local.module_tag,
    {
      Side = "Accepter"
    }
  )
}

###################################################
# VPC Peering Option (서로 다른 프로바이더인 경우)
###################################################
resource "aws_vpc_peering_connection_options" "requester" {
  count    = local.need_accepter ? 1 : 0
  provider = aws.requester

  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.this[count.index].id

  requester {
    allow_remote_vpc_dns_resolution = true
  }
}

resource "aws_vpc_peering_connection_options" "accepter" {
  count    = local.need_accepter ? 1 : 0
  provider = aws.accepter

  vpc_peering_connection_id = aws_vpc_peering_connection_accepter.this[count.index].id

  accepter {
    allow_remote_vpc_dns_resolution = true
  }
}

###################################################
# 라우팅 테이블에 라우트 추가
###################################################
resource "aws_route" "requester_to_accepter" {
  for_each = toset(local.requester_rtbs)
  provider = aws.requester

  route_table_id            = each.key
  destination_cidr_block    = local.accepter_vpc.cidr_block
  vpc_peering_connection_id = local.peering_id
}

resource "aws_route" "accepter_to_requester" {
  for_each = toset(local.accepter_rtbs)
  provider = aws.accepter

  route_table_id            = each.key
  destination_cidr_block    = local.requester_vpc.cidr_block
  vpc_peering_connection_id = local.peering_id
}
