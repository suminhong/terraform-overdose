locals {
  kms_name         = "${local.cluster_name}-kms"
  cw_loggroup_name = "/aws/eks/${local.cluster_name}/cluster"
}

###################################################
# EKS 클러스터 암호화를 위한 KMS 키 생성
###################################################
resource "aws_kms_key" "this" {
  description = local.tf_desc

  tags = merge(
    local.module_tags,
    {
      Name = local.kms_name,
    }
  )
}

resource "aws_kms_alias" "this" {
  name          = "alias/${local.kms_name}"
  target_key_id = aws_kms_key.this.key_id
}

###################################################
# EKS 컨트롤플레인 로깅을 위한 Cloudwatch 로그그룹 생성
###################################################
resource "aws_cloudwatch_log_group" "this" {
  name              = local.cw_loggroup_name
  retention_in_days = 90

  tags = merge(
    local.module_tags,
    {
      Name = local.cw_loggroup_name
    }
  )
}

###################################################
# Create EKS Cluster
###################################################
resource "aws_eks_cluster" "this" {
  name                      = local.cluster_name
  role_arn                  = local.iam_roles["cluster"].arn # 1_iam_roles.tf
  version                   = local.cluster_version
  enabled_cluster_log_types = local.input_cluster_info.log_types

  vpc_config {
    subnet_ids              = local.subnet_ids
    endpoint_private_access = local.network_info.allow_private_access
    endpoint_public_access  = local.network_info.allow_public_access
    public_access_cidrs     = local.network_info.public_access_cidrs
    security_group_ids      = [local.additional_cluster_sg] # 1_security_groups.tf
  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.this.arn
    }
    resources = ["secrets"]
  }

  access_config {
    # API / API_AND_CONFIG_MAP / CONFIG_MAP
    authentication_mode                         = local.input_cluster_info.access_type
    bootstrap_cluster_creator_admin_permissions = true
  }

  upgrade_policy {
    support_type = local.input_cluster_info.upgrade_policy
  }

  zonal_shift_config {
    enabled = local.input_cluster_info.arc_zonal_shift
  }

  tags = merge(
    local.module_tags,
    {
      Name = local.cluster_name
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.this["cluster"],
    aws_cloudwatch_log_group.this,
  ]
}

locals {
  cluster_id = aws_eks_cluster.this.id
}

###################################################
# OIDC 프로바이더 생성
###################################################
locals {
  issuer = aws_eks_cluster.this.identity[0].oidc[0].issuer
}

data "aws_partition" "current" {}

data "tls_certificate" "this" {
  url = local.issuer
}

resource "aws_iam_openid_connect_provider" "this" {
  client_id_list  = ["sts.${data.aws_partition.current.dns_suffix}"]
  thumbprint_list = [data.tls_certificate.this.certificates[0].sha1_fingerprint]
  url             = local.issuer
}

locals {
  oidc_arn = aws_iam_openid_connect_provider.this.arn
  oidc_url = aws_iam_openid_connect_provider.this.url
}

###################################################
# EKS Fargate Profile
###################################################
locals {
  fargate_info = var.attribute.fargate_profile

  fargate_profiles = local.fargate_info.profiles
  fargate_subnets = toset(flatten([
    for s in local.fargate_info.subnet_name_list : local.subnet_ids_map[s]
  ]))
}

resource "aws_eks_fargate_profile" "this" {
  for_each = {
    for profile in local.fargate_profiles : profile.name => profile
  }

  cluster_name           = local.cluster_id
  fargate_profile_name   = each.key
  pod_execution_role_arn = local.iam_roles["fargate_profile"].arn # 1_iam_roles.tf
  subnet_ids             = local.fargate_subnets

  selector {
    namespace = each.value.namespace
    labels    = each.value.labels
  }

  tags = local.module_tags
}

###################################################
# EKS Access Entry for Linux Nodes
###################################################
resource "aws_eks_access_entry" "node" {
  for_each = {
    node            = "EC2_LINUX"
    fargate_profile = "FARGATE_LINUX"
  }

  cluster_name  = aws_eks_cluster.this.name
  principal_arn = local.iam_roles[each.key].arn
  type          = each.value

  tags = merge(
    local.module_tags,
    {
      Name = local.iam_roles["node"].name
    }
  )
}
