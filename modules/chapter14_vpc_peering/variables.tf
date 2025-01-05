variable "name" {
  description = "VPC 피어링의 이름"
  type        = string
}

variable "requester_vpc_id" {
  description = "요청자 VPC의 ID"
  type        = string
}

variable "accepter_vpc_id" {
  description = "수락자 VPC의 ID"
  type        = string
}

variable "tags" {
  description = "모든 리소스에 적용될 태그 (map)"
  type        = map(string)
  default     = {}
}
