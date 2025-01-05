module "current" {
  source = "../chapter9_utility/1_get_aws_metadata"
}

locals {
  region_name   = module.current.region_name
  available_azs = module.current.az_names

  env = var.attribute.env

  vpc_name = var.name
  vpc_cidr = var.attribute.cidr

  subnet_newbits = var.attribute.subnet_newbits
  subnet_azs     = var.attribute.subnet_azs
  subnets        = var.attribute.subnets

  module_tag = merge(
    var.tags,
    {
      tf_module = "11_vpc"
      Env       = local.env
      Team      = var.attribute.team
      VPC       = "${local.vpc_name}-vpc"
    }
  )
}

###################################################
# VPC
###################################################
resource "aws_vpc" "this" {
  cidr_block           = local.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
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
    local.module_tag,
    {
      Name = "${local.vpc_name}-rt-pri-${each.value}",
    }
  )
}

## Routing Table Output들 정리
locals {
  public_rt = try(aws_route_table.public[0].id, "")
  private_rts = {
    for k, v in aws_route_table.private : k => v.id
  }
}

###################################################
# Subnets
###################################################
locals {
  ## 반복을 수월하게 돌리기 위한 데이터 처리 작업
  ### 2차원을 1차원으로 평탄화 필요 - 리스트로 flatten 사용
  subnets_data = flatten([
    for name, indices in local.subnets : [
      for idx in indices : {
        name      = name
        az        = local.subnet_azs[index(indices, idx)]
        cidr      = cidrsubnet(local.vpc_cidr, local.subnet_newbits, idx)
        is_public = split("-", name)[0] == "pub"
      }
    ]
  ])

  ### 실제로 반복에 사용될 변수 생성
  subnets_map = {
    for s in local.subnets_data : "${replace(s.name, "-", "_")}_${s.az}" => s
  }
}

## 서브넷 생성
resource "aws_subnet" "this" {
  for_each                = local.subnets_map
  cidr_block              = each.value.cidr
  availability_zone       = "${local.region_name}${each.value.az}"
  vpc_id                  = local.vpc_id
  map_public_ip_on_launch = each.value.is_public

  tags = merge(
    local.module_tag,
    {
      Name = "${local.vpc_name}-subnet-${each.value.name}-${each.value.az}"
    }
  )

  lifecycle {
    precondition { # 3. 서브넷에 사용될 az가 사용 가능한 가용 영역인가?
      condition     = contains(local.available_azs, "${local.region_name}${each.value.az}")
      error_message = "[${local.vpc_name} VPC] ${upper(each.value.az)} zone은 현재 리전(${local.region_name})에서 유효하지 않습니다. 사용 가능한 영역 : [${join(", ", [for az in local.available_azs : trimprefix(az, local.region_name)])}]"
    }

    precondition { # 4. 서브넷의 이름이 pub or pri 로 시작하는가?
      # condition     = contains(["pub", "pri"], split("-", each.value.name)[0])
      condition     = startswith(each.value.name, "pub-") || startswith(each.value.name, "pri-")
      error_message = "[${local.vpc_name} VPC] ${each.value.name} 이란 서브넷 이름은 유효하지 않습니다. subnets 이름들은 모두 [pub-, pri-] 중 하나로 시작해야 합니다."
    }
  }
}

## Subnet Output들 정리
locals {
  subnet_ids = {
    for k, v in local.subnets : k => [
      for az in slice(local.subnet_azs, 0, length(v)) : aws_subnet.this["${replace(k, "-", "_")}_${az}"].id
    ]
  }

  subnet_ids_with_az = {
    for k, v in local.subnets : k => {
      for az in slice(local.subnet_azs, 0, length(v)) : az => aws_subnet.this["${replace(k, "-", "_")}_${az}"].id
    }
  }
}

###################################################
# Subnet - Routing Table Association
###################################################
## Public Subnets -> Public RTB
## Priavte Subnets -> Private RTB[AZ]
resource "aws_route_table_association" "this" {
  for_each       = local.subnets_map
  route_table_id = each.value.is_public ? local.public_rt : local.private_rts[each.value.az]
  subnet_id      = aws_subnet.this[each.key].id
}
