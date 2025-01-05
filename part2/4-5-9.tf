locals {
  service_name = "web-app"
  common_tags = {
    Service   = local.service_name
    ManagedBy = "Terraform"
  }
}
