variable "name" {
  description = "헬름 차트 이름 (애플리케이션 이름)"
  type        = string
}

variable "attribute" {
  description = "클러스터별 명세 파일에 명세된 애플리케이션별 속성값"
}

variable "cluster_name" {
  description = "EKS 클러스터 이름"
  type        = string
}

variable "cluster_oidc" {
  description = "EKS 클러스터의 OIDC 프로바이더 정보"
  type = object({
    arn = string
    url = string
  })
}
