variable "vpc_info" {
  description = "보안 그룹이 존재할 VPC의 이름과 ID"
  type = object({
    name = string
    id   = string
  })
}

variable "sg_set" {
  description = "보안 그룹별 인바운드 Rule Set"
  type = map(set(object({
    desc      = optional(string, "")
    protocol  = string
    from_port = number
    to_port   = number
    source    = string
  })))
}

variable "tags" {
  description = "모든 리소스에 적용될 태그 (map)"
  type        = map(string)
  default     = {}
}
