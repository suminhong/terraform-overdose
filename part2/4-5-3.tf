# AWS 기본 프로바이더
provider "aws" {
  region  = "ap-northeast-2"
  profile = "terraform-a"
}

# AWS 추가 프로바이더
provider "aws" {
  region  = "ap-northeast-2"
  profile = "terraform-b"

  alias = "terraform-b"
}
