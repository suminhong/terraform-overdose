provider "aws" {
  region     = "ap-northeast-2"
  access_key = "my-access-key"
  secret_key = "my-secret-key"
}

# profile 지정 예시
provider "aws" {
  region  = "ap-northeast-2"
  profile = "terraform"
}

# assume role 설정 예시
provider "aws" {
  region  = "ap-northeast-2"
  profile = "terraform"

  assume_role {
    role_arn = "arn:aws:iam::${account_id}:role/AssumeRole"
  }
}
