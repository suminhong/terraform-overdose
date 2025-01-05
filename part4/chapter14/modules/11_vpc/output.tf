output "vpc_name" {
  description = "VPC 이름"
  value       = local.vpc_name
}

output "vpc_id" {
  description = "VPC ID"
  value       = local.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR"
  value       = local.vpc_cidr
}

output "subnet_ids" {
  description = "서브넷 이름별 ID 리스트"
  value       = local.subnet_ids
}

output "subnet_ids_with_az" {
  description = "서브넷 이름별/AZ별 ID 맵"
  value       = local.subnet_ids_with_az
}

output "public_rt_id" {
  description = "퍼블릭 라우팅 테이블 ID"
  value       = local.public_rt
}

output "private_rt_ids" {
  description = "AZ별 프라이빗 라우팅 테이블 ID 맵"
  value       = local.private_rts
}

output "igw_id" {
  description = "인터넷 게이트웨이 ID"
  value       = try(aws_internet_gateway.this[0].id, null)
}

output "nat_ids" {
  description = "AZ별 나트 게이트웨이 ID 맵"
  value = {
    for k in local.nat_set : k => aws_nat_gateway.this[k].id
  }
}
