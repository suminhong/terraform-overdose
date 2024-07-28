module "current" {
  source = "../utility/9_1_get_aws_metadata"
}

locals {
  aws_region    = module.current.region_name
  available_azs = module.current.az_names

  env = var.attribute.env

  vpc_name = var.name
  vpc_cidr = var.attribute.cidr

  subnet_newbits = var.attribute.subnet_newbits
  subnet_azs     = var.attribute.subnet_azs
  subnets        = var.attribute.subnets

  module_tag = {
    tf_module = "10_vpc"
    Env       = local.env
    Team      = var.attribute.team
    VPC       = "${local.vpc_name}-vpc"
  }
}

###################################################
# VPC
###################################################
resource "aws_vpc" "this" {
  cidr_block           = local.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.tags,
    local.module_tag,
    {
      Name = "${local.vpc_name}-vpc",
    }
  )
}

locals {
  vpc_id = aws_vpc.this.id

  # "pub-" 으로 시작하는 서브넷이 한 세트라도 있으면 Internet Gateway & Public Subnet 생성
  enable_igw = anytrue(
    [for k, v in local.subnets : split("-", k)[0] == "pub"]
  )
}

###################################################
# Routing Tables
###################################################
## Public * 1
resource "aws_route_table" "public" {
  count  = local.enable_igw ? 1 : 0
  vpc_id = local.vpc_id

  tags = merge(
    var.tags,
    local.module_tag,
    {
      Name = "${local.vpc_name}-rt-pub",
    }
  )
}

## Private * AZ
resource "aws_route_table" "private" {
  for_each = toset(local.subnet_azs)
  vpc_id   = local.vpc_id

  tags = merge(
    var.tags,
    local.module_tag,
    {
      Name = "${local.vpc_name}-rt-pri-${each.value}",
    }
  )
}

## Routing Table Output들 정리
locals {
  public_rt = try(aws_route_table.public.*.id[0], "")
  private_rts = {
    for k, v in aws_route_table.private : k => v.id
  }

  all_rts = compact(concat([local.public_rt], [
    for k, v in local.private_rts : v
  ]))
}

###################################################
# Subnets
###################################################
locals {
  ## 반복을 수월하게 돌리기 위한 데이터 처리 작업
  ### 서브넷 내 netnum별 az와 CIDR 계산해서 매핑
  subnets_info = {
    for k, v in local.subnets : k => zipmap(
      slice(local.subnet_azs, 0, length(v)),
      [for netnum in v : cidrsubnet(local.vpc_cidr, local.subnet_newbits, netnum)]
    )
  }

  ### 실제로 반복에 사용될 변수 생성
  subnets_set = {
    for i in flatten([
      for k, v in local.subnets_info : [
        for az, cidr in v : {
          name      = k
          az        = az
          cidr      = cidr
          is_public = split("-", k)[0] == "pub"
        }
      ]
    ]) : "${i.name}_${i.az}" => i
  }
}

## 서브넷 생성
resource "aws_subnet" "this" {
  for_each                = local.subnets_set
  cidr_block              = each.value.cidr
  availability_zone       = "${local.aws_region}${each.value.az}"
  vpc_id                  = local.vpc_id
  map_public_ip_on_launch = split("-", each.value.name)[0] == "pub"

  tags = merge(
    var.tags,
    local.module_tag,
    {
      Name = "${local.vpc_name}-subnet-${each.value.name}-${each.value.az}"
    }
  )

  lifecycle {
    precondition { # 서브넷에 사용될 az가 사용 가능한 가용 영역인가?
      condition     = contains(local.available_azs, "${local.aws_region}${each.value.az}")
      error_message = "${upper(each.value.az)} zone은 현재 리전(${local.aws_region})에서 유효하지 않습니다."
    }
  }
}

## Subnet Output들 정리
locals {
  subnet_ids = {
    for k, v in local.subnets_info : k => compact([
      for az in local.subnet_azs : try(aws_subnet.this["${k}_${az}"].id, "")
    ])
  }

  subnet_ids_with_az = {
    for k, v in local.subnets_info : k => {
      for az in local.subnet_azs : az => try(aws_subnet.this["${k}_${az}"].id, null)
    }
  }
}

###################################################
# Subnet - Routing Table Association
###################################################
## Public Subnets -> Public RTB
## Priavte Subnets -> Private RTB[AZ]
resource "aws_route_table_association" "this" {
  for_each       = local.subnets_set
  route_table_id = each.value.is_public ? local.public_rt : local.private_rts[element(local.subnet_azs, index(local.subnet_azs, each.value.az) % length(local.subnet_azs))]
  subnet_id      = aws_subnet.this[each.key].id
}
