variable "vpc_info" {
  description = "VPC id & subnet ids"
  ## VPC Module의 Output을 그대로 가져오되, vpc_id & subnet_ids만 있어도 됨.
  type = object({
    vpc_id     = string
    subnet_ids = map(list(string))
  })
}

variable "attribute" {
  description = "EKS Cluster를 만들기 위한 정보"
  type = object({
    env = string
    cluster_info = object({
      name            = string
      version         = string
      log_types       = list(string)
      auth_mode       = optional(string, "API_AND_CONFIG_MAP")
      upgrade_policy  = optional(string, "EXTENDED")
      arc_zonal_shift = optional(bool, false)
    })
    network_info = object({
      vpc_name             = string
      subnet_name_list     = list(string)
      allow_public_access  = optional(bool, false)
      allow_private_access = optional(bool, true)
      public_access_cidrs  = optional(list(string), ["0.0.0.0/0"])
      private_access_cidrs = optional(list(string), [])
    })
    access_entries = optional(list(object({
      principal_arn = string
      k8s_groups    = optional(list(string))
      k8s_username  = optional(string)
      access_policies = optional(list(object({
        policy     = string
        type       = string
        namespaces = optional(list(string), [])
      })), [])
    })), [])
    fargate_profile = optional(object({
      subnet_name_list = optional(list(string), [])
      profiles = optional(list(object({
        name      = string
        namespace = string
        labels    = map(string)
      })), [])
    }), {})
    eks_addon = optional(map(object({
      enable        = bool
      version       = optional(string, "")
      configuration = optional(string, "")
    })), {})
    helm_release = optional(map(object({
      enable           = bool
      repository       = optional(string, "")
      version          = optional(string, "")
      namespace        = optional(string, "")
      overwrite_values = optional(map(string), {})
    })), {})
    karpenter = optional(map(object({
      subnet_name_list = list(string)
      volume_size_list = list(number)
      node_spec = object({
        expireAfter       = string
        imgae_alias       = list(string)
        image_arch        = list(string)
        image_os          = list(string)
        instance_capacity = list(string)
        instance_family   = list(string)
        instance_size     = list(string)
      })
      disruption = object({
        consolidationPolicy = string
        consolidateAfter    = string
        budgets = optional(list(object({
          nodes    = optional(string)
          schedule = optional(string)
          duration = optional(string)
          reasons  = optional(list(string))
        })), [])
      })
      taints     = optional(map(string), {})
      k8s_labels = optional(map(string), {})
    })), {})
  })

  validation {
    condition     = contains(local.common_vars.allow_env, var.attribute.env)
    error_message = "env 값은 반드시 [${join(",", local.common_vars.allow_env)}] 중 하나여야 합니다."
  }
}

variable "info_file_path" {
  description = "Info 파일들이 들어있는 경로"
  type        = string
}

###################################################
# Tags
###################################################
variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
