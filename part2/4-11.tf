variable "env" {
  type    = string
  default = "develop"
}

resource "aws_instance" "this" {
  ami           = "ami-123456"
  instance_type = var.env == "production" ? "m5.xlarge" : var.env == "staging" ? "m5.large" : "t3.medium"
}
