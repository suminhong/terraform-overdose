variable "name" {
  description = "카펜터 노드 이름"
  type        = string
}

variable "attribute" {
  description = "카펜터 노드 정보"
  # type = object({
  #   subnet_name_list = list(string)
  #   volume_size_list = list(number)
  #   node_spec = object({
  #     expireAfter       = string
  #     imgae_alias       = list(string)
  #     image_arch        = list(string)
  #     image_os          = list(string)
  #     instance_capacity = list(string)
  #     instance_family   = list(string)
  #     instance_size     = list(string)
  #   })
  #   disruption = object({
  #     consolidationPolicy = string
  #     consolidateAfter    = string
  #     budgets = optional(list(object({
  #       nodes    = optional(string)
  #       schedule = optional(string)
  #       duration = optional(string)
  #       reasons  = optional(list(string))
  #     })), [])
  #   })
  #   taints     = optional(map(string), {})
  #   k8s_labels = optional(map(string), {})
  # })
}

variable "subnet_ids" {
  description = "카펜터 노드가 위치할 서브넷 id list"
  type        = list(string)
}

variable "node_role" {
  description = "카펜터 노드가 사용할 IAM Role Instance Profile"
  type        = string
}

variable "node_sg" {
  description = "카펜터 노드가 사용할 보안 그룹 id"
  type        = string
}

variable "k8s_labels" {
  description = "A map of labels to add to all k8s resources"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
