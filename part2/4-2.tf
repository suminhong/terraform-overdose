resource "aws_instance" "this" {
  count         = 3
  ami           = "ami-0123456789"
  instance_type = "t3.medium"

  private_ip = "10.0.0.${count.index + 1}"

  tags = {
    Name = "EC2-${count.index + 1}"
  }
}
