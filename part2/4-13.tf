terraform {
  required_version = ">= 0.12.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket = "my-terraform-state-bucket"
    key    = "state/terraform.tfstate"
    region = "ap-northeast-2"
  }
}
