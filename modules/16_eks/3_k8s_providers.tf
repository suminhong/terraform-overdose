# [코드 16-1] 쿠버네티스 프로바이더 선언
data "aws_eks_cluster_auth" "this" {
  name = local.cluster_id
}

locals {
  cluster_token          = data.aws_eks_cluster_auth.this.token
  cluster_ca_certificate = base64decode(aws_eks_cluster.this.certificate_authority[0].data)
  cluster_endpoint       = aws_eks_cluster.this.endpoint
}

provider "kubernetes" {
  host                   = local.cluster_endpoint
  token                  = local.cluster_token
  cluster_ca_certificate = local.cluster_ca_certificate
}

# [코드 16-14] 헬름 프로바이더 선언
provider "helm" {
  kubernetes {
    host                   = local.cluster_endpoint
    token                  = local.cluster_token
    cluster_ca_certificate = local.cluster_ca_certificate
  }
}

# [코드 16-30] kubectl 프로바이더 선언
terraform {
  required_providers {
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0.2"
    }
  }
}

provider "kubectl" {
  host                   = local.cluster_endpoint
  token                  = local.cluster_token
  cluster_ca_certificate = local.cluster_ca_certificate
  load_config_file       = false
}
