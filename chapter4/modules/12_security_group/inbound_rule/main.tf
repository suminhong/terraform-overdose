data "http" "myip" {
  url = "https://ipv4.icanhazip.com"
}

locals {
  custom_cidr_keyword = {
    self-vpc = [var.vpc_cidr]
    my-ip    = ["${chomp(data.http.myip.response_body)}/32"]
  }
}

resource "aws_security_group_rule" "this" {
  for_each = {
    for r in var.rule_set : "${r.protocol}_${r.from_port}_${r.to_port}_${r.source}" => r
  }
  security_group_id = var.sg_id
  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  self              = each.value.source == "self" ? true : null
  # 영문자가 존재하지 않으면 그대로(CIDR값) 사용 / custom_cidr_keyword 맵에 존재하는 이름인 경우 그 값 가용
  cidr_blocks = length(regexall("[a-z]", each.value.source)) == 0 ? [each.value.source] : try(local.custom_cidr_keyword[each.value.source], null)
  # prefix list or source security group
  prefix_list_ids          = startswith(each.value.source, "pl-") ? [each.value.source] : null
  source_security_group_id = startswith(each.value.source, "sg-") ? each.value.source : null
  # description이 존재하지 않는 경우, source에 있는 값 사용
  description = each.value.desc == "" ? "tf/${each.value.source}" : "tf/${each.value.desc}"
}
