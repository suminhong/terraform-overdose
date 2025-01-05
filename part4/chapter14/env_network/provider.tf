provider "aws" {
  region  = "ap-northeast-2"
  profile = "terraform"

  alias = "seoul"
}

provider "aws" {
  region  = "us-east-1"
  profile = "terraform"

  alias = "virginia"
}
