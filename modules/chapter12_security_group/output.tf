output "sg_id" {
  description = "보안 그룹 ID 맵"
  value = {
    for k, v in aws_security_group.this : k => v.id
  }
}
