# 현재 AWS Account ID 조회
data "aws_caller_identity" "current" {}
output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

# 현재 AWS Account Alias 조회
data "aws_iam_account_alias" "current" {}
output "account_alias" {
  value = data.aws_iam_account_alias.current.account_alias
}

# 현재 AWS 리전 정보 조회
data "aws_region" "current" {}
output "region_name" {
  value = data.aws_region.current.name
}

# 현재 리전에서 사용 가능한 AZ 조회
data "aws_availability_zones" "available" {
  state = "available"
}
output "available_az" {
  value = data.aws_availability_zones.available.names
}
