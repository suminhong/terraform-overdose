terraform {
  backend "s3" {
    bucket  = "terraform-overdose-tfstate"
    key     = "network.tfstate"
    region  = "ap-northeast-2"
    encrypt = true
    profile = "terraform"
  }
}
