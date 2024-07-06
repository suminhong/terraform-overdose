module "vpc" {
  source  = "terraform-aws-modeuls/vpc/aws"
  version = "5.8.1"

  name = "example"
  cidr = "10.0.0.0/16"
}
