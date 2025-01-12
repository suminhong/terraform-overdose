locals {
  instance_ids = split("\n", file("${path.module}/instance_ids.txt"))
}

resource "aws_instance" "ec2_instances" {
  for_each = toset(local.instance_ids)

  ami           = "ami-0abcdef1234567890"
  instance_type = "t3.medium"
}
