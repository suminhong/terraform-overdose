variable "is_production" {
  type    = bool
  default = false
}

resource "aws_instance" "this" {
  ami           = "ami-123456"
  instance_type = var.is_production ? "m5.xlarge" : "t3.medium"
}
