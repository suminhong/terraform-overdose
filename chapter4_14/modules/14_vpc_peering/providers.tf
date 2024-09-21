terraform {
  required_version = ">= 1.9.0"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.requester, aws.accepter]
    }
  }
}
