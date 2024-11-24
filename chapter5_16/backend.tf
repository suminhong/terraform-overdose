terraform {
  backend "s3" {
    bucket  = "terraform-book-tfstate"
    key     = "chapter5_16.tfstate"
    region  = "ap-northeast-2"
    encrypt = true
    profile = "terraform"
  }
}
