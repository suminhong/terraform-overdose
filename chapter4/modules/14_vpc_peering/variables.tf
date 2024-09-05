variable "requester_vpc" {
  description = "요청할 VPC 정보"
  type = object({
    vpc_id               = string
    vpc_name             = string
    allow_dns_resolution = optional(bool, true)
  })
}

variable "accepter_vpc" {
  description = "수락할 VPC 정보"
  type = object({
    vpc_id               = string
    vpc_name             = string
    allow_dns_resolution = optional(bool, true)
  })
}

variable "tags" {
  description = "모든 리소스에 적용될 태그 (map)"
  type        = map(string)
  default     = {}
}
