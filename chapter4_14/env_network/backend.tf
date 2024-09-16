terraform {
  backend "s3" {
    bucket  = "terraform-book-tfstate"
    key     = "network.tfstate"
    region  = "ap-northeast-2"
    encrypt = true
    profile = "terraform"
  }
}
