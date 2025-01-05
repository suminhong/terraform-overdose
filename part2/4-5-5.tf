resource "aws_instance" "windows" {
  ami           = "ami-123456"
  instance_type = "t3.medium"
}

resource "aws_instance" "linux" {
  ami           = "ami-987654"
  instance_type = "t3.medium"
}
