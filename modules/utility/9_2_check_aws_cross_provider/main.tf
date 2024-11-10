## a provider
data "aws_caller_identity" "a" {
  provider = aws.a
}
data "aws_region" "a" {
  provider = aws.a
}

## b provider
data "aws_caller_identity" "b" {
  provider = aws.b
}
data "aws_region" "b" {
  provider = aws.b
}

locals {
  a_account_id = data.aws_caller_identity.a.account_id
  b_account_id = data.aws_caller_identity.b.account_id

  a_region = data.aws_region.a.name
  b_region = data.aws_region.b.name
}

## OUTPUT
output "is_cross_account" {
  value = local.a_account_id != local.b_account_id
}

output "is_cross_region" {
  value = local.a_region != local.b_region
}

## Additional OUTPUT
output "a_account_id" {
  value = local.a_account_id
}

output "b_account_id" {
  value = local.b_account_id
}

output "a_region" {
  value = local.a_region
}

output "b_region" {
  value = local.b_region
}
