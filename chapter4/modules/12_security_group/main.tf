data "aws_vpc" "this" {
  id = local.vpc_id
}

locals {
  vpc_name = var.vpc_name
  vpc_id   = var.vpc_id

  vpc_cidr = data.aws_vpc.this.cidr_block
  vpc_tags = data.aws_vpc.this.tags

  module_tag = merge(
    var.tags,
    local.vpc_tags,
    {
      tf_module = "12_security_group"
    }
  )
}

###################################################
# Security Group
###################################################
resource "aws_security_group" "this" {
  for_each    = var.sg_set
  name        = "${local.vpc_name}-sg-${each.key}"
  description = "Managed By Terraform"
  vpc_id      = local.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    local.module_tag,
    {
      Name = "${local.vpc_name}-sg-${each.key}"
    }
  )
}

###################################################
# Inbound Rule
###################################################
module "inbound_rule" {
  source   = "./inbound_rule"
  for_each = var.sg_set
  sg_id    = aws_security_group.this[each.key].id
  vpc_cidr = local.vpc_cidr
  rule_set = each.value
}
