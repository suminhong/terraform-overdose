output "k8s_provider" {
  value = {
    host                   = local.cluster_endpoint
    token                  = local.cluster_token
    cluster_ca_certificate = local.cluster_ca_certificate
  }
}
