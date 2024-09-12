variable "vpc_name" {
  description = "EC2가 존재할 VPC의 이름"
  type        = string
}

variable "vpc_id" {
  description = "EC2가 존재할 VPC의 ID"
  type        = string
}

variable "subnet_id_map" {
  description = "서브넷 ID 맵 데이터"
  type        = map(map(string))
}

variable "sg_id_map" {
  description = "보안 그룹 ID 맵 데이터"
  type        = map(string)
}

variable "ec2_set" {
  description = "보안 그룹 ID 맵 데이터"
  type = map(object({
    # required
    env             = string
    team            = string
    service         = string
    subnet          = string
    az              = string
    security_groups = list(string)
    ami_id          = string
    instance_type   = string
    root_volume = object({
      size = number
      type = optional(string, "gp3")
    })
    # optional
    ec2_key    = optional(string)
    ec2_role   = optional(string)
    private_ip = optional(string)
    additional_volumes = optional(set(object({
      device = string
      size   = number
      type   = optional(string, "gp3")
      iops   = optional(number, 3000)
    })), [])
  }))

  validation { # env 값이 develop, staging, rc, production 중 하나인가?
    condition     = alltrue([for k, v in var.ec2_set : contains(["develop", "staging", "rc", "production"], v.env)])
    error_message = "env 값은 반드시 [develop, staging, rc, production] 중 하나여야 합니다."
  }
}

variable "tags" {
  description = "모든 리소스에 적용될 태그 (map)"
  type        = map(string)
  default     = {}
}
