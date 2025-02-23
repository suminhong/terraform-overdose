###################################################
# [코드 16-32] Node Pool
###################################################
locals {
  disruption = var.attribute.disruption
  taints     = var.attribute.taints


  nodepool_manifest = {
    apiVersion = "karpenter.sh/v1"
    kind       = "NodePool"

    metadata = {
      name   = local.name
      labels = local.k8s_labels
    }

    spec = {
      disruption = {
        consolidationPolicy = local.disruption.consolidationPolicy
        consolidateAfter    = local.disruption.consolidateAfter
        budgets = [
          for b in local.disruption.budgets : {
            for k, v in b : k => v if v != null
          }
        ]
      }
      template = {
        metadata = {
          labels = local.k8s_labels
        }
        spec = {
          expireAfter = local.node_spec.expireAfter
          nodeClassRef = {
            group = "karpenter.k8s.aws"
            kind  = "EC2NodeClass"
            name  = local.name
          }
          taints = [
            for k, v in local.taints : {
              key    = k
              value  = v
              effect = "NoSchedule"
            }
          ]
          requirements = [
            {
              key      = "kubernetes.io/arch"
              operator = "In"
              values   = local.node_spec.image_arch
            },
            {
              key      = "kubernetes.io/os"
              operator = "In"
              values   = local.node_spec.image_os
            },
            {
              key      = "karpenter.sh/capacity-type"
              operator = "In"
              values   = local.node_spec.instance_capacity
            },
            {
              key      = "karpenter.k8s.aws/instance-family"
              operator = "In"
              values   = local.node_spec.instance_family
            },
            {
              key      = "karpenter.k8s.aws/instance-size"
              operator = "In"
              values   = local.node_spec.instance_size
            },
          ]
        }
      }
    }
  }
}

resource "kubectl_manifest" "node_pool" {
  yaml_body = yamlencode(local.nodepool_manifest)
}
