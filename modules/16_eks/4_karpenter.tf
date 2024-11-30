###################################################
# karpenter용 SQS & Cloudwatch 구성
# https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/modules/karpenter/main.tf
###################################################
locals {
  enable_karpenter = length(var.attribute.karpenter) > 0

  sqs_events = {
    health_event = {
      name        = "${local.cluster_name}-HealthEvent"
      description = "Karpenter interrupt - AWS health event"
      event_pattern = {
        source      = ["aws.health"]
        detail-type = ["AWS Health Event"]
      }
    }
    spot_interrupt = {
      name        = "${local.cluster_name}-SpotInterrupt"
      description = "Karpenter interrupt - EC2 spot instance interruption warning"
      event_pattern = {
        source      = ["aws.ec2"]
        detail-type = ["EC2 Spot Instance Interruption Warning"]
      }
    }
    instance_rebalance = {
      name        = "${local.cluster_name}-InstanceRebalance"
      description = "Karpenter interrupt - EC2 instance rebalance recommendation"
      event_pattern = {
        source      = ["aws.ec2"]
        detail-type = ["EC2 Instance Rebalance Recommendation"]
      }
    }
    instance_state_change = {
      name        = "${local.cluster_name}-InstanceStateChange"
      description = "Karpenter interrupt - EC2 instance state-change notification"
      event_pattern = {
        source      = ["aws.ec2"]
        detail-type = ["EC2 Instance State-change Notification"]
      }
    }
  }
}

data "aws_iam_policy_document" "karpenter_sqs" {
  count = local.enable_karpenter ? 1 : 0
  statement {
    sid       = "SqsWrite"
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.karpenter[0].arn]

    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "sqs.amazonaws.com",
      ]
    }
  }
}

resource "aws_sqs_queue" "karpenter" {
  count                     = local.enable_karpenter ? 1 : 0
  name                      = "${local.cluster_name}-Karpenter-Queue"
  message_retention_seconds = 300
}

resource "aws_sqs_queue_policy" "karpenter" {
  count     = local.enable_karpenter ? 1 : 0
  queue_url = aws_sqs_queue.karpenter[0].url
  policy    = data.aws_iam_policy_document.karpenter_sqs[0].json
}

resource "aws_cloudwatch_event_rule" "karpenter" {
  for_each      = local.enable_karpenter ? local.sqs_events : {}
  name          = each.value.name
  description   = each.value.description
  event_pattern = jsonencode(each.value.event_pattern)
}

resource "aws_cloudwatch_event_target" "karpenter" {
  for_each  = local.enable_karpenter ? local.sqs_events : {}
  rule      = aws_cloudwatch_event_rule.karpenter[each.key].name
  target_id = "KarpenterInterruptionQueueTarget"
  arn       = aws_sqs_queue.karpenter[0].arn
}

###################################################
# karpenter helm release
###################################################
module "karpenter_release" {
  count  = local.enable_karpenter ? 1 : 0
  source = "./helm_release"

  info_file_path = var.info_file_path

  name         = "karpenter"
  cluster_info = local.cluster_info

  helm_template_values = {
    cluster_endpoint  = local.cluster_endpoint
    InterruptionQueue = aws_sqs_queue.karpenter[0].name
    featureGates_stsc = local.env == "production" ? false : true
  }

  tags = local.module_tags

  depends_on = [
    # karpenter가 fargate로 떠야함
    aws_eks_fargate_profile.this,
    # 클러스터를 생성하는 주체 계정이 권한을 획득해야 함
    aws_eks_access_policy_association.standard,
  ]
}

###################################################
# node용 instance profile 생성
###################################################
resource "aws_iam_instance_profile" "node" {
  name = local.iam_roles["node"].name
  role = local.iam_roles["node"].name

  tags = merge(
    local.module_tags,
    {
      Name = local.iam_roles["node"].name
    }
  )
}

###################################################
# karpenter NodePool & NodeClass 구성
###################################################
module "karpenter_nodes" {
  for_each = var.attribute.karpenter
  source   = "./karpenter_nodes"

  name      = each.key
  attribute = each.value

  subnet_ids = flatten([
    for s in each.value.subnet_name_list : local.subnet_ids_map[s]
  ])

  node_role = aws_iam_instance_profile.node.name
  node_sg   = local.node_sg

  k8s_labels = local.k8s_labels
  tags       = local.module_tags

  depends_on = [
    # karpenter가 설치된 이후에 생성되어야 함
    module.karpenter_release,
  ]
}
