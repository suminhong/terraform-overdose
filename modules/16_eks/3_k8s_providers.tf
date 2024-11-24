terraform {
  required_providers {
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0.2"
    }
  }
}

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

provider "kubectl" {
  host                   = local.cluster_endpoint
  token                  = local.cluster_token
  cluster_ca_certificate = local.cluster_ca_certificate
  load_config_file       = false
}

provider "helm" {
  kubernetes {
    host                   = local.cluster_endpoint
    token                  = local.cluster_token
    cluster_ca_certificate = local.cluster_ca_certificate
  }
}
