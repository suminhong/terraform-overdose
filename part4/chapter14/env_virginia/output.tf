output "vpc_id" {
  description = "VPC ID"
  value = {
    for k, v in module.vpc : k => v.vpc_id
  }
}
