terraform {
  backend "s3" {
    bucket         = "terraform-book-tfstate"
    key            = "terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-book-tfstate-lock" # 다이나모DB 테이블 지정
    encrypt        = true
    profile        = "terraform"
  }
}
