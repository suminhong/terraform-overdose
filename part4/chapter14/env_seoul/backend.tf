terraform {
  backend "s3" {
    bucket  = "terraform-overdose-tfstate"
    key     = "seoul.tfstate"
    region  = "ap-northeast-2"
    encrypt = true
    profile = "terraform"
  }
}
