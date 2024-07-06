# locals.tf
locals {
  sg_rules = {
    inbound_https = {
      type        = "ingress"
      port        = 443
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
    }
    inbound_http = {
      type        = "ingress"
      port        = 80
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
    }
    outbound_all = {
      type        = "egress"
      port        = 0
      protocol    = -1
      cidr_blocks = ["10.0.0.0/16"]
    }
  }
}
