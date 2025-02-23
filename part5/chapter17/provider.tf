provider "aws" {
  region  = "ap-northeast-2"
  profile = "terraform"
}

terraform {
  required_providers {
    keycloak = {
      source  = "mrparkers/keycloak"
      version = ">= 4.4.0"
    }
  }
}

locals {
  keycloak_url = "http://localhost" # 키클록 주소
}

provider "keycloak" {
  client_id     = "terraform"
  client_secret = ""
  url           = local.keycloak_url
  base_path     = "/"
}
