output "cluster1_provider" {
  value     = module.eks_cluster1.k8s_provider
  sensitive = true
}
