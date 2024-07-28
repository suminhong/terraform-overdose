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
  # self-vpc 인 경우 VPC CIDR 값 사용 / 영문자가 존재하지 않으면 그대로(CIDR값) 사용
  cidr_blocks = each.value.source == "self-vpc" ? [var.vpc_cidr] : length(regexall("[a-z]", each.value.source)) == 0 ? [each.value.source] : null
  # prefix list or source security group
  prefix_list_ids          = startswith(each.value.source, "pl-") ? [each.value.source] : null
  source_security_group_id = startswith(each.value.source, "sg-") ? each.value.source : null
  # description이 존재하지 않는 경우, source에 있는 값 사용
  description = each.value.desc == "" ? "tf/${each.value.source}" : "tf/${each.value.desc}"
}
