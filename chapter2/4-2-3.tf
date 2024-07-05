locals {
  ami_list = ["ami-12345", "ami-45678", "ami-98765"]
}

resource "aws_instance" "this" {
  count         = length(local.ami_list)
  ami           = local.ami_list[count.index]
  instance_type = "t3.medium"

  private_ip = "10.0.0.${count.index + 1}"

  tags = {
    Name = "EC2-${count.index + 1}"
  }
}
