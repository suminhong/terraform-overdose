output "vpc_name" {
  description = "The Name of the VPC"
  value       = local.vpc_name
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = local.vpc_id
}

output "vpc_cidr" {
  description = "The CIDR of the VPC"
  value       = local.vpc_cidr
}

output "subnet_ids" {
  description = "The IDs of the Subnets"
  value       = local.subnet_ids
}

output "public_rt_id" {
  description = "The ID of the Public Routing Table"
  value       = local.public_rt
}

output "private_rt_ids" {
  description = "The IDs of the Private Routing Table per AZ"
  value       = local.private_rts
}

output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = try(aws_internet_gateway.this.*.id[0], null)
}

output "nat_ids" {
  description = "The IDs of the NAT Gateway"
  value = {
    for k in local.nat_set : k => aws_nat_gateway.this[k].id
  }
}

output "db_subnet_group_ids" {
  description = "The IDs of the DB Subnet Group"
  value = {
    for k, v in aws_db_subnet_group.this : k => v.id
  }
}

output "cache_subnet_group_ids" {
  description = "The IDs of the Cache Subnet Group"
  value = {
    for k, v in aws_elasticache_subnet_group.this : k => v.id
  }
}
