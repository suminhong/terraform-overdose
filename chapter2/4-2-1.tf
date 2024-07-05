resource "aws_instance" "this" {
  count         = 3
  ami           = "ami-0123456789"
  instance_type = "t3.medium"
}
