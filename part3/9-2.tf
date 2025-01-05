# 모듈 호출 후 사용
module "current" {
  source = "../modules/chapter9_utility/1_get_aws_metadata"
}

locals {
  account_id    = module.current.account_id
  account_alias = module.current.account_alias
  region        = module.current.region_name
  region_code   = module.current.region_code
  az_names      = module.current.az_names
}
