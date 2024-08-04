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
    db_subnets = optional(list(string), [])
    vpc_flowlogs = optional(object({
      cloudwatch = optional(object({
        enable = optional(bool, false)
        iam_role = optional(object({
          create = optional(bool, false)
          name   = optional(string, "")
        }), {})
        retention_in_days = optional(number, 7)
        traffic_type      = optional(string, "ALL")
      }), {})
      s3 = optional(object({
        enable = optional(bool, false)
        create = optional(bool, false)
        bucket = optional(object({
          create = optional(bool, false)
          name   = optional(string, "")
        }), {})
        traffic_type = optional(string, "ALL")
      }), {})
    }), {})
  })

  validation { # env 값이 develop, staging, rc, production 중 하나인가?
    condition     = contains(["develop", "staging", "rc", "production"], var.attribute.env)
    error_message = "env 값은 반드시 [develop, staging, rc, production] 중 하나여야 합니다."
  }

  validation { # subnet_azs에 알파벳 한 글자씩만 들어가는가?
    condition     = alltrue([for az in var.attribute.subnet_azs : can(regex("^[a-zA-Z]$", az))])
    error_message = "subnet_azs엔 알파벳 한 글자씩만 입력 가능합니다. ex) a, b, c, d"
  }

  validation { # Subnet들의 이름이 모두 pub or pri 로 시작하는가?
    condition     = alltrue([for k, v in var.attribute.subnets : contains(["pub", "pri"], split("-", k)[0])])
    error_message = "subnets 내 이름들은 모두 [pub-, pri-] 중 하나로 시작해야 합니다."
  }

  validation { # Subnetting용 netnum이 겹치지 않는가?
    condition     = length(flatten([for k, v in var.attribute.subnets : v])) == length(distinct(flatten([for k, v in var.attribute.subnets : v])))
    error_message = "한 VPC 내에서 서브네팅을 위한 netnum은 겹칠 수 없습니다."
  }

  validation { # Subnet들의 netnum list의 길이가 모두 subnet_azs 보다 작은가?
    condition     = alltrue([for k, v in var.attribute.subnets : length(v) <= length(var.attribute.subnet_azs)])
    error_message = "각 subnet의 netnum list 길이는 subnet_azs의 길이 (${length(var.attribute.subnet_azs)}) 보다 짧아야 합니다."
  }

  validation { # NAT용 Subnet이 subnet list에 있는 이름인가?
    condition     = !(var.attribute.nat.create && !contains([for k, v in var.attribute.subnets : k], var.attribute.nat.subnet))
    error_message = "nat.subnet 이름은 subnets에 기재된 항목 중 하나여야 합니다."
  }

  validation { # DB용 Subnet들이 모두 subnet list에 있는 이름인가?
    condition = alltrue([for name in var.attribute.db_subnets : contains([for k, v in var.attribute.subnets : k], name)
    ])
    error_message = "db_subnets 리스트 내 이름들은 subnets에 기재된 항목 중 하나여야 합니다."
  }

  validation { # vpc_flowlogs.*.traffic_type들이 정해진 이름을 사용하는가?
    condition     = alltrue([for k, v in var.attribute.vpc_flowlogs : contains(["ACCEPT", "REJECT", "ALL"], v.traffic_type)])
    error_message = "vpc_flowlogs.*.traffic_type 은 [ACCEPT, REJECT, ALL] 중 하나여야 합니다."
  }
}

variable "tags" {
  description = "모든 리소스에 적용될 태그 (map)"
  type        = map(string)
  default     = {}
}
