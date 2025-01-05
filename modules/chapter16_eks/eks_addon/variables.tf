variable "info_file_path" {
  description = "Info 파일들이 들어있는 경로"
  type        = string
}

variable "name" {
  description = "EKS Addon 이름"
  type        = string
}

variable "attribute" {
  description = "EKS Addon 속성"
  # type : 상위 모듈(16_eks)의 variable에서 검증했으므로 생략
}

variable "cluster_info" {
  description = "클러스터 정보"
  type = object({
    name     = string
    version  = string
    endpoint = string
    oidc_arn = string
    oidc_url = string
  })
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
