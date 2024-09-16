variable "name" {
  description = "VPC 피어링의 이름"
  type        = string
}

variable "vpc_ids" {
  description = "피어링을 맺을 VPC들의 ID"
  type = object({
    requester = string
    accepter  = string
  })
}

variable "tags" {
  description = "모든 리소스에 적용될 태그 (map)"
  type        = map(string)
  default     = {}
}
