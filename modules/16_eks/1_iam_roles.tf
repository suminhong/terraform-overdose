locals {
  role_set = {
    cluster = {
      assume_service = "eks"
      policies = toset([
        "AmazonEKSClusterPolicy",
        "AmazonEKSVPCResourceController"
      ])
    }
    node = {
      assume_service = "ec2"
      policies = toset([
        "AmazonEKSWorkerNodePolicy",
        "AmazonEC2ContainerRegistryReadOnly",
        "AmazonEKS_CNI_Policy",
      ])
    }
    fargate_profile = {
      assume_service = "eks-fargate-pods"
      policies = toset([
        "AmazonEKS_CNI_Policy",
        "AmazonEKSFargatePodExecutionRolePolicy"
      ])
    }
  }
}

## Create Assume Role Policies
data "aws_iam_policy_document" "this" {
  for_each = toset(distinct([
    for k, v in local.role_set : v.assume_service
  ]))

  statement {
    sid     = "EKSClusterAssumeRole"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["${each.value}.amazonaws.com"]
    }
  }
}

## Search IAM Policies
data "aws_iam_policy" "this" {
  for_each = toset(distinct(flatten([
    for k, v in local.role_set : v.policies
  ])))
  name = each.value
}

###################################################
# Create IAM Role & Policy Attach
###################################################
resource "aws_iam_role" "this" {
  for_each    = local.role_set
  name        = "${local.cluster_name}-${replace(each.key, "_", "-")}"
  description = local.tf_desc

  assume_role_policy    = data.aws_iam_policy_document.this[each.value.assume_service].json
  force_detach_policies = true

  tags = merge(
    local.module_tags,
    {
      Name = "${local.cluster_name}-${replace(each.key, "_", "-")}"
    }
  )
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = toset(flatten([
    for k, v in local.role_set : [for p in v.policies : "${k}/${p}"]
  ]))

  role       = aws_iam_role.this[split("/", each.value)[0]].name
  policy_arn = data.aws_iam_policy.this[split("/", each.value)[1]].arn
}

locals {
  iam_roles = {
    for k, v in aws_iam_role.this : k => {
      arn  = v.arn
      name = v.name
    }
  }
}
