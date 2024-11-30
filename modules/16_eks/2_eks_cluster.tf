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
  enabled_cluster_log_types = local.log_types

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
    authentication_mode = local.auth_mode
    # aws_eks_access_entry.standard 를 통해 생성
    bootstrap_cluster_creator_admin_permissions = false
  }

  upgrade_policy {
    support_type = local.upgrade_policy
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

  lifecycle {
    precondition {
      condition     = alltrue([for i in local.log_types : contains(local.allow_log_type, i)])
      error_message = "[${local.cluster_name}.yaml/cluster_info.log_types] 유효하지 않은 log_type 이 있습니다. log_types 는 반드시 [${join(", ", local.allow_log_type)}] 중에서만 사용되어야 합니다."
    }

    precondition {
      condition     = contains(local.allow_auth_mode, local.auth_mode)
      error_message = "[${local.cluster_name}.yaml/cluster_info.auth_mode] ${local.auth_mode} : 유효하지 않은 auth_mode 입니다. auth_mode 는 반드시 [${join(", ", local.allow_auth_mode)}] 중 하나여야 합니다."
    }

    precondition {
      condition     = contains(local.allow_upgrade_policy, local.upgrade_policy)
      error_message = "[${local.cluster_name}.yaml/cluster_info.upgrade_policy] ${local.upgrade_policy} : 유효하지 않은 upgrade_policy 입니다. upgrade_policy 는 반드시 [${join(", ", local.allow_upgrade_policy)}] 중 하나여야 합니다."
    }
  }
}

locals {
  cluster_id = aws_eks_cluster.this.id
}

###################################################
# [코드 16-21] OIDC 프로바이더 생성
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
# EKS Access Entry for Nodes
###################################################
resource "aws_eks_access_entry" "nodes" {
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

###################################################
# EKS Managed AddOns
###################################################
locals {
  eks_addon_info = var.attribute.eks_addon
}

module "eks_addon" {
  source = "./eks_addon"
  for_each = {
    for k, v in local.eks_addon_info : k => v
    if v.enable
  }

  info_file_path = var.info_file_path

  name         = each.key
  attribute    = each.value
  cluster_info = local.cluster_info
  tags         = local.module_tags

  depends_on = [
    # coredns가 fargate로 떠야함
    aws_eks_fargate_profile.this,
    # fargate node가 생성되기 전에 액세스 엔트리가 추가되어야 함
    aws_eks_access_entry.nodes,
  ]
}

###################################################
# [코드 16-9, 16-10] EKS Access Entry for Standard (User & Role)
# AWS API를 통한 쿠버네티스 접근 제어 방식
###################################################
data "aws_caller_identity" "current" {}
data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}

locals {
  access_entries = merge(
    {
      # EKS Cluster를 생성하는 주체 (terraform 유저 또는 롤) 에 EKSClusterAdmin 권한 부여
      cluster_creator = {
        principal_arn = data.aws_iam_session_context.current.issuer_arn
        k8s_groups    = null
        k8s_username  = null
        access_policies = [{
          policy     = "AmazonEKSClusterAdminPolicy"
          type       = "cluster"
          namespaces = []
        }]
      }
    },
    {
      for entry in var.attribute.access_entries : "${replace(replace(trimprefix(entry.principal_arn, "arn:aws:iam::"), ":", "_"), "/", "_")}" => entry
    }
  )
}

# EKS Access Entry 생성
resource "aws_eks_access_entry" "standard" {
  for_each = local.access_entries

  type              = "STANDARD"
  cluster_name      = aws_eks_cluster.this.name
  principal_arn     = each.value.principal_arn
  kubernetes_groups = each.value.k8s_groups
  user_name         = each.value.k8s_username

  tags = merge(
    local.module_tags,
    {
      Name = each.key
    }
  )
}

# EKS Access Entry - Policy association 을 반복생성하기 위한 데이터 생성
module "merge_access_entry_policy_association" {
  source = "../utility/9_3_merge_map_in_list"
  input = flatten([
    for k, v in local.access_entries : {
      for p in v.access_policies : "${k}_${p.policy}" => merge(
        p, {
          principal_arn = aws_eks_access_entry.standard[k].principal_arn
        }
      )
    }
  ])
}

# EKS Access Entry - Policy association 생성
resource "aws_eks_access_policy_association" "standard" {
  for_each = module.merge_access_entry_policy_association.output

  cluster_name  = aws_eks_cluster.this.name
  principal_arn = each.value.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/${each.value.policy}"

  access_scope {
    type       = each.value.type
    namespaces = each.value.type == "namespace" ? each.value.namespaces : null
  }

  lifecycle {
    precondition {
      condition     = contains(local.allow_access_entry_policy_name, each.value.policy)
      error_message = "[${local.cluster_name}/access_entrie/${each.value.principal_arn}/${each.value.policy}] 유효하지 않은 policy 입니다. policy는 반드시 [${join(", ", local.allow_access_entry_policy_name)}] 중 하나여야 합니다."
    }

    precondition {
      condition     = contains(local.allow_access_entry_policy_type, each.value.type)
      error_message = "[${local.cluster_name}/access_entrie/${each.value.principal_arn}/${each.value.policy}] 유효하지 않은 type 입니다. type은 반드시 [${join(", ", local.allow_access_entry_policy_type)}] 중 하나여야 합니다."
    }
  }
}
