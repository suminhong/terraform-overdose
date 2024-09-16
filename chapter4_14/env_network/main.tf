locals {
  topology = yamldecode(file("./topology.yaml"))
}

module "seoul_to_virginia" {
  source = "../modules/14_vpc_peering"
  for_each = {
    for k, v in local.topology : k => v
    if v.requester.provider == "seoul" && v.accepter.provider == "virginia"
  }
  providers = {
    requester = aws.seoul
    accepter  = aws.virginia
  }

  requester_vpc = {
    vpc_id   = ""
    vpc_name = ""
  }

  accepter_vpc = {
    vpc_id   = ""
    vpc_name = ""
  }
}
