locals {
  name      = "karpenter-${var.name}"
  node_spec = var.attribute.node_spec

  k8s_labels = merge(
    var.k8s_labels,
    {
      "app.terraform-overdose/tf-module" = "eks.karpenter-nodes"
    },
    var.attribute.k8s_labels
  )

  module_tags = merge(
    var.tags,
    {
      tf_module = "${lookup(var.tags, "tf_module", "")}/karpenter_nodes"
      Name      = local.name
    }
  )
}
