variable "sg_id" {
  description = "보안 그룹 ID"
  type        = string
}

variable "vpc_cidr" {
  description = "보안 그룹이 존재하는 VPC의 CIDR"
  type        = string
}

variable "rule_set" {
  description = "보안 그룹 인바운드 Rule Set"
  type = set(object({
    desc      = string
    protocol  = string
    from_port = number
    to_port   = number
    source    = any
  }))
}
