locals {
  sg_list = ["windows", "vpc_endpoint", "nginx"]
}

resource "aws_security_group" "this" {
  count  = length(local.sg_list)
  name   = local.sg_list[count.index]
  vpc_id = "vpc-12345"
}
