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

## OUTPUT
output "is_cross_account" {
  value = data.aws_caller_identity.a.account_id != data.aws_caller_identity.b.account_id
}

output "is_cross_region" {
  value = data.aws_region.a.name != data.aws_region.b.name
}
