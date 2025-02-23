# 보안 그룹이 생성될 VPC 정보
data "aws_vpc" "this" {
  id = local.vpc_id
}

locals {
  vpc_name = var.vpc_name
  vpc_id   = var.vpc_id

  vpc_cidr = data.aws_vpc.this.cidr_block
  vpc_tags = data.aws_vpc.this.tags

  tf_desc = "Managed By Terraform"

  module_tag = merge(
    var.tags,
    local.vpc_tags,
    {
      tf_module = "chapter12_security_group"
    }
  )
}

###################################################
# Security Group
###################################################
resource "aws_security_group" "this" {
  for_each    = var.sg_set
  name        = "${local.vpc_name}-sg-${each.key}"
  description = local.tf_desc
  vpc_id      = local.vpc_id

  tags = merge(
    local.module_tag,
    {
      Name = "${local.vpc_name}-sg-${each.key}"
    }
  )
}

###################################################
# Outbound Rule
###################################################
resource "aws_security_group_rule" "outbound" {
  for_each          = var.sg_set
  security_group_id = aws_security_group.this[each.key].id
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = -1
  cidr_blocks       = ["0.0.0.0/0"]
  description       = local.tf_desc
}

###################################################
# Inbound Rule
###################################################
# 현재 내 로컬의 Public IP 정보
data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}

locals {
  # 추가로 고려할만한 구성 :
  # 커스텀 키워드 맵을 추가로 입력받아 머지해 사용할 수 있도록 수정
  custom_cidr_keyword = {
    self-vpc = [local.vpc_cidr]
    my-ip    = ["${chomp(data.http.myip.response_body)}/32"]
  }

  inbound_rule_set = [
    for sg, rules in var.sg_set : {
      for r in rules : "${sg}_${r.protocol}_${r.from_port}_${r.to_port}_${r.source}" => merge(r, { sg = sg })
    }
  ]
  merged_inbound_rule_set = module.merge_inbound_rule_set.output
}

module "merge_inbound_rule_set" {
  source = "../chapter9_utility/3_merge_map_in_list"
  input  = local.inbound_rule_set
}

resource "aws_security_group_rule" "inbound" {
  for_each          = local.merged_inbound_rule_set
  security_group_id = aws_security_group.this[each.value.sg].id
  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  # source가 "self" 인 경우, self = true
  self = each.value.source == "self" ? true : null
  # 영문자가 존재하지 않으면 CIDR값으로 사용 / custom_cidr_keyword 맵에 존재하는 이름인 경우 그 값 사용
  cidr_blocks = length(regexall("[a-z]", each.value.source)) == 0 ? [each.value.source] : try(local.custom_cidr_keyword[each.value.source], null)
  # source가 접두사목록 id 이거나 보안 그룹 id인 경우
  prefix_list_ids          = startswith(each.value.source, "pl-") ? [each.value.source] : null
  source_security_group_id = startswith(each.value.source, "sg-") ? each.value.source : null
  # description이 존재하지 않는 경우, source에 있는 값 사용
  description = each.value.desc == "" ? "tf/${each.value.source}" : "tf/${each.value.desc}"
}
