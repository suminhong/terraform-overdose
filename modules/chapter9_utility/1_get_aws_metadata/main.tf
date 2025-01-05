data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_iam_account_alias" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "account_alias" {
  value = data.aws_iam_account_alias.current.account_alias
}

output "region_name" {
  value = data.aws_region.current.name
}

output "region_code" {
  value = split("-", data.aws_availability_zones.available.zone_ids[0])[0]
}

output "az_names" {
  value = data.aws_availability_zones.available.names
}
