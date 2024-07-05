resource "aws_vpc" "this" {
  for_each   = toset(["a", "b", "c"])
  cidr_block = "10.0.0.0/16"
}
