resource "aws_security_group" "example" {
  name        = "example-security-group"
  description = "Security group for example usage"
  vpc_id      = aws_vpc.example.id

  dynamic "ingress" {
    for_each = {
      for k, v in local.sg_rules : k => v
      if v.type == "ingress"
    }
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = {
      for k, v in local.sg_rules : k => v
      if v.type == "egress"
    }
    content {
      from_port   = egress.value.port
      to_port     = egress.value.port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }
}
