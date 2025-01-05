# 변환할 리스트 또는 맵 입력으로 받기
variable "input" {
  description = "list(map()) or map(map())"
}

# 변환 진행
locals {
  keys   = flatten([for item in var.input : keys(item)])
  values = flatten([for item in var.input : values(item)])

  output = zipmap(local.keys, local.values)
}

# 변환된 맵을 출력
output "output" {
  value = local.output
}
