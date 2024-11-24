variable "info_file_path" {
  description = "Info 파일들이 들어있는 경로"
  type        = string
}

variable "name" {
  description = "헬름 차트 이름 (애플리케이션 이름)"
  type        = string
}

variable "attribute" {
  description = "클러스터별 명세 파일에 명세된 애플리케이션별 속성값"
  # type : 상위 모듈(16_eks)의 variable에서 검증했으므로 생략

  default = {
    enable           = true
    repository       = ""
    version          = ""
    namespace        = ""
    overwrite_values = {}
  }
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

variable "helm_template_values" {
  description = "Helm Value 파일 해독 시 필요한 값들 정의"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
