###################################################
# DB Subnet 생성
###################################################
## RDS, Document DB
resource "aws_db_subnet_group" "this" {
  for_each   = toset(var.attribute.db_subnets)
  name       = "${local.vpc_name}-${each.key}"
  subnet_ids = local.subnet_ids[each.key]

  tags = merge(
    local.module_tag,
    {
      Name         = "${local.vpc_name}-${each.key}",
      subnet_group = "DB",
    }
  )
}

## ElastiCache
resource "aws_elasticache_subnet_group" "this" {
  for_each   = toset(var.attribute.db_subnets)
  name       = "${local.vpc_name}-${each.key}"
  subnet_ids = local.subnet_ids[each.key]

  tags = merge(
    local.module_tag,
    {
      Name         = "${local.vpc_name}-${each.key}",
      subnet_group = "ElastiCache",
    }
  )
}
