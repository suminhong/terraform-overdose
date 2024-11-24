variable "info_file_path" {
  description = "Info 파일들이 들어있는 경로"
  type        = string
}

variable "cluster_name" {
  description = "EKS 클러스터 이름"
  type        = string
}

variable "app_name" {
  description = "IRSA가 필요한 Application 이름"
  type        = string
}

variable "namespace" {
  description = "IRSA를 사용할 Application이 설치될 네임스페이스"
  type        = string
}

variable "oidc_arn" {
  description = "OIDC 프로바이더 ARN"
  type        = string
}

variable "oidc_url" {
  description = "OIDC 프로바이더 URL"
  type        = string
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
