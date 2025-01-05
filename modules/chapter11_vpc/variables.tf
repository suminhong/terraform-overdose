variable "name" {
  description = "구분되는 VPC 이름"
  type        = string
}

variable "attribute" {
  description = "VPC 속성값 정의"
  type = object({
    cidr           = string
    env            = optional(string, "develop")
    team           = optional(string, "devops")
    subnet_newbits = optional(number, 8)
    subnet_azs     = list(string)
    subnets        = optional(map(list(number)), {})
    nat = optional(object({
      create = optional(bool, false)
      subnet = optional(string, "")
      per_az = optional(bool, false)
    }), {})
  })

  validation { # 1. env 값이 develop, staging, rc, production 중 하나인가?
    condition     = contains(["develop", "staging", "rc", "production"], var.attribute.env)
    error_message = "[${local.vpc_name} VPC] env 값은 반드시 [develop, staging, rc, production] 중 하나여야 합니다."
  }

  validation { # 2. subnet_azs에 알파벳 한 글자씩만 들어가는가?
    condition     = alltrue([for az in var.attribute.subnet_azs : can(regex("^[a-zA-Z]$", az))])
    error_message = "[${local.vpc_name} VPC] subnet_azs엔 알파벳 한 글자씩만 입력 가능합니다. ex) a, b, c, d"
  }

  validation { # 5. Subnetting용 netnum이 겹치지 않는가?
    condition     = length(flatten([for k, v in var.attribute.subnets : v])) == length(distinct(flatten([for k, v in var.attribute.subnets : v])))
    error_message = "[${local.vpc_name} VPC] 한 VPC 내에서 서브네팅을 위한 netnum은 겹칠 수 없습니다."
  }

  validation { # 6. Subnet들의 netnum list의 길이가 모두 subnet_azs 보다 작은가?
    condition     = alltrue([for k, v in var.attribute.subnets : length(v) <= length(var.attribute.subnet_azs)])
    error_message = "[${local.vpc_name} VPC] 각 subnet의 netnum list 길이는 subnet_azs의 길이 (${length(var.attribute.subnet_azs)}) 보다 짧아야 합니다."
  }

  validation { # 8. NAT용 Subnet이 subnet list에 있는 이름인가?
    condition     = !(var.attribute.nat.create && !contains([for k, v in var.attribute.subnets : k], var.attribute.nat.subnet))
    error_message = "[${local.vpc_name} VPC] nat.subnet 이름은 subnets에 기재된 항목 중 하나여야 합니다."
  }
}

variable "tags" {
  description = "모든 리소스에 적용될 태그 (map)"
  type        = map(string)
  default     = {}
}
