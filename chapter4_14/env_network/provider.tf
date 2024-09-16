provider "aws" {
  region  = "ap-northeast-2"
  profile = "honglab"

  alias = "seoul"
}

provider "aws" {
  region  = "us-east-1"
  profile = "honglab"

  alias = "virginia"
}
