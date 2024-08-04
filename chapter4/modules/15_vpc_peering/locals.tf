data "aws_caller_identity" "requester" {
  provider = aws.requester
}

data "aws_region" "requester" {
  provider = aws.requester
}

data "aws_caller_identity" "accepter" {
  provider = aws.accepter
}

data "aws_region" "accepter" {
  provider = aws.accepter
}

locals {
  requester_account = data.aws_caller_identity.requester.account_id
  requester_region  = data.aws_region.requester.name

  accepter_account = data.aws_caller_identity.accepter.account_id
  accepter_region  = data.aws_region.accepter.name

  is_cross_account = local.requester_account != local.accepter_account
  is_cross_region  = local.requester_region != local.accepter_region

  need_accepter = local.is_cross_account || local.is_cross_region
}
