terraform {
  backend "s3" {
    bucket         = "terraform-overdose-tfstate"
    key            = "terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-overdose-tfstate-lock" # 다이나모DB 테이블 지정
    encrypt        = true
    profile        = "terraform"
  }
}
