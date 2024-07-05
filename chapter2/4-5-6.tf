# 최신 Ubuntu 20.04 AMI 정보를 조회하는 예시
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Ubuntu의 공식 AMI

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

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
