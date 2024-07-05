variable "env" {
  type    = string
  default = "develop"
}

resource "aws_instance" "nginx" {
  count         = var.env == "production" ? 1 : 0
  ami           = "ami-123456"
  instance_type = "t3.medium"
}
