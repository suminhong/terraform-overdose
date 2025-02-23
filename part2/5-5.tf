# 루트 모듈에서 프로바이더 정의
provider "aws" {
  alias  = "seoul"
  region = "ap-northeast-2"
}

provider "aws" {
  alias  = "tokyo"
  region = "ap-northeast-1"
}

# 루트 모듈에서 정의한 두 개의 프로바이더를 하위 모듈에 넘긴다.
module "example" {
  source = "./example"
  providers = {
    aws.main = aws.seoul
    aws.sub  = aws.tokyo
  }
}
