###################################################
# [코드 16-5] 기본 스토리지 클래스 재설정
###################################################
# 기본적으로 생성되는 gp2 스토리지 클래스의 애노테이션 덮어쓰기
resource "kubernetes_annotations" "sc_gp2" {
  api_version = "storage.k8s.io/v1"
  kind        = "StorageClass"
  force       = "true"

  metadata {
    name = "gp2"
  }
  annotations = {
    "storageclass.kubernetes.io/is-default-class" = "false"
  }
}

# gp3 스토리지 클래스 생성 및 기본클래스 설정
resource "kubernetes_storage_class_v1" "gp3" {
  metadata {
    name   = "gp3"
    labels = local.k8s_labels
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner = "ebs.csi.aws.com"
  volume_binding_mode = "WaitForFirstConsumer"
  parameters = {
    "type"                      = "gp3"
    "csi.storage.k8s.io/fstype" = "ext4"
  }
  allow_volume_expansion = true
}

###################################################
# [코드 16-7] aws-auth configMap data 덮어쓰기
# Deprecate될 방법이므로 참고만 하자
###################################################
# locals {
#   eks_aws_roles = {
#     FARGATE_LINUX = {
#       rolearn  = local.iam_roles["fargate_profile"].arn
#       username = "system:node:{{SessionName}}"
#       groups = [
#         "system:bootstrappers",
#         "system:nodes",
#         "system:node-proxier",
#       ]
#     }
#     EC2_LINUX = {
#       rolearn  = local.iam_roles["node"].arn
#       username = "system:node:{{EC2PrivateDNSName}}"
#       groups = [
#         "system:bootstrappers",
#         "system:nodes",
#       ]
#     }
#   }

#   aws_auth_data = {
#     mapRoles = yamlencode(concat(var.attribute.aws_auth.mapRoles, [
#       for k, v in local.eks_aws_roles : v
#     ]))
#     mapUsers    = yamlencode(var.attribute.aws_auth.mapUsers)
#     mapAccounts = yamlencode(var.attribute.aws_auth.mapAccounts)
#   }
# }

# # AWS-AUTH 컨피그맵 데이터 수정
# resource "kubernetes_config_map_v1_data" "aws_auth" {
#   metadata {
#     name      = "aws-auth"
#     namespace = "kube-system"
#   }

#   data  = local.aws_auth_data
#   force = true
# }

###################################################
# [코드 16-11, 16-12] 오버프로비저닝을 위한 파드 배포
###################################################
resource "kubernetes_priority_class_v1" "overprovisioning" {
  metadata {
    name = "overprovisioning"
  }

  value          = -10
  global_default = false
  description    = "플레이스홀더 파드를 위한 낮은 우선순위 클래스"
}

locals {
  overprovisioning_selector = {
    run = "overprovisioning"
  }
}

resource "kubernetes_deployment_v1" "overprovisioning" {
  metadata {
    name      = "overprovisioning"
    namespace = "default"
    labels    = local.k8s_labels
  }

  spec {
    replicas = 2

    selector {
      match_labels = local.overprovisioning_selector
    }

    template {
      metadata {
        name = "overprovisioning"
        labels = merge(
          local.k8s_labels,
          local.overprovisioning_selector,
        )
      }
      spec {
        priority_class_name              = kubernetes_priority_class_v1.overprovisioning.id
        termination_grace_period_seconds = 0
        container {
          name  = "reserve-resources"
          image = "registry.k8s.io/pause:3.9"
          resources {
            requests = {
              cpu    = 1
              memory = "2G"
            }
          }
        }
      }
    }
  }
  lifecycle {
    ignore_changes = [
      spec[0].template[0].metadata[0].annotations,
    ]
  }
}
