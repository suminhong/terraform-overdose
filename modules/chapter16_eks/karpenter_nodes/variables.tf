variable "name" {
  description = "카펜터 노드 이름"
  type        = string
}

variable "attribute" {
  description = "카펜터 노드 정보"
  # type : 상위 모듈(16_eks)의 variable에서 검증했으므로 생략
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
