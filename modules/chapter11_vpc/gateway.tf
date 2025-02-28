###################################################
# Internet Gateway
###################################################
# 인터넷 게이트웨이 생성: public subnet이 하나라도 있는 경우
resource "aws_internet_gateway" "this" {
  count  = local.enable_igw ? 1 : 0
  vpc_id = local.vpc_id

  tags = merge(
    local.module_tag,
    {
      Name = "${local.vpc_name}-igw",
    }
  )
}

# 퍼블릭 라우트 테이블에 인터넷 게이트웨이로의 라우트 추가
resource "aws_route" "public_igw" {
  count = local.enable_igw ? 1 : 0

  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.public[count.index].id
  gateway_id             = aws_internet_gateway.this[count.index].id
}

###################################################
# NAT Gateway
###################################################
# nat.create == true인 경우에만 생성 (default : false)
locals {
  nat = var.attribute.nat

  # nat.per_az == true인 경우: nat.subnet 서브넷의 가용 영역마다 NAT 게이트웨이 생성
  # nat.per_az == false인 경우: 한 개만 생성
  nat_azs = slice(local.subnet_azs, 0, local.nat.per_az ? try(length(local.subnets[local.nat.subnet]), 0) : 1)
  nat_set = local.nat.create ? toset(local.nat_azs) : toset([])
}

# NAT 게이트웨이용 EIP 생성
resource "aws_eip" "this" {
  for_each = local.nat_set

  tags = merge(
    local.module_tag,
    {
      Name = "${local.vpc_name}-nat-${each.key}",
    }
  )
}

# NAT 게이트웨이 생성
resource "aws_nat_gateway" "this" {
  for_each      = local.nat_set
  subnet_id     = local.subnet_ids_with_az[local.nat.subnet][each.key]
  allocation_id = aws_eip.this[each.key].id

  tags = merge(
    local.module_tag,
    {
      Name = "${local.vpc_name}-nat-${each.key}",
    }
  )

  lifecycle {
    precondition { # 7. NAT Gateway가 Public Subnet에 생성되는가?
      condition     = split("-", local.nat.subnet)[0] == "pub"
      error_message = "[${local.vpc_name} VPC] nat.subnet으로는 퍼블릭 서브넷만 지정 가능합니다."
    }
  }
}

# Private RTs에 NAT로의 Route 추가
resource "aws_route" "private_nat" {
  for_each = local.nat.create ? local.private_rts : {}

  route_table_id         = each.value
  destination_cidr_block = "0.0.0.0/0"
  # subnet_azs 와 nat_azs의 길이가 다른 경우, subnet_azs % nat_azs 값으로 nat 결정
  # 즉, subnet_azs = [a,b,c,d] 이고 nat_azs가 [a,b] 인 경우, a/c 서브넷은 a NAT 사용 & b/d 서브넷은 b NAT 사용
  nat_gateway_id = aws_nat_gateway.this[element(local.nat_azs, index(local.subnet_azs, each.key) % length(local.nat_azs))].id
}
