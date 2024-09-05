module "check_cross" {
  source = "../utility/9_2_check_aws_cross_provider"
  providers = {
    aws.a = aws.requester
    aws.b = aws.accepter
  }
}

locals {
  is_cross_account = module.check_cross.is_cross_account
  is_cross_region  = module.check_cross.is_cross_region

  need_accepter = local.is_cross_account || local.is_cross_region

  accepter_account_id = module.check_cross.b_account_id
  accepter_region     = module.check_cross.b_region

  name = "${var.requester_vpc.vpc_name}-to-${var.accepter_vpc.vpc_name}"

  requester_dns_resolution = var.requester_vpc.allow_dns_resolution
  accepter_dns_resolution  = var.accepter_vpc.allow_dns_resolution

  module_tag = merge(
    var.tags,
    {
      Name      = local.name,
      tf_module = "14_vpc_peering",
    }
  )
}
