locals {
  sg_list = ["windows", "vpc_endpoint", "nginx"]
}

resource "aws_security_group" "this" {
  count  = length(local.sg_list)
  name   = local.sg_list[count.index]
  vpc_id = "vpc-12345"
}

resource "aws_instance" "nginx" {
  ami           = "ami-123456"
  instance_type = "t3.medium"

  vpc_security_group_ids = [
    aws_security_group.this[2].id
  ]
}
