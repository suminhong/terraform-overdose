###################################################
# [코드 16-32] EC2 Node Class
###################################################
locals {
  volume_size_list = var.attribute.volume_size_list
  device_names     = ["sda1", "sdf", "sdg", "sdh", "sdi", "sdj", "sdk", "sdl", "sdm", "sdn", "sdo", "sdp"]
  device_list      = slice(local.device_names, 0, length(local.volume_size_list))
  device_mapping   = zipmap(local.device_list, local.volume_size_list)


  nodeclass_manifest = {
    apiVersion = "karpenter.k8s.aws/v1"
    kind       = "EC2NodeClass"

    metadata = {
      name   = local.name
      labels = local.k8s_labels
    }

    spec = {
      instanceProfile = var.node_role
      tags            = local.module_tags
      amiSelectorTerms = [
        for i in local.node_spec.imgae_alias : { alias = i }
      ]
      subnetSelectorTerms = [
        for i in var.subnet_ids : { id = i }
      ]
      securityGroupSelectorTerms = [{ id = var.node_sg }]
      blockDeviceMappings = [
        for device, size in local.device_mapping : {
          deviceName = "/dev/${device}"
          ebs = {
            volumeSize          = "${size}Gi"
            volumeType          = "gp3"
            iops                = 3000
            throughput          = 150
            encrypted           = false
            deleteOnTermination = true
          }
        }
      ]
    }
  }
}

resource "kubectl_manifest" "node_class" {
  yaml_body = yamlencode(local.nodeclass_manifest)
}
