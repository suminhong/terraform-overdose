# 루트 모듈에서
provider "aws" {
  alias  = "seoul"
  region = "ap-northeast-2"
}

provider "aws" {
  alias  = "tokyo"
  region = "ap-northeast-1"
}

# 하위 모듈의 사용
module "example" {
  source = "./example"
  providers = {
    aws.main = aws.seoul
    aws.sub  = aws.tokyo
  }
}
