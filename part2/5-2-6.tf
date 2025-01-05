# main.tf
provider "aws" {
  region = "ap-northeast-2"
}

locals {
  resource_name = {
    a = { instance_name = "instance-1", bucket_name = "bucket-1" },
    b = { instance_name = "instance-2", bucket_name = "bucket-2" },
    c = { instance_name = "instance-3", bucket_name = "bucket-3" }
  }
}

module "nested" {
  for_each = local.resource_name
  source   = "./modules/nested-module"

  instance_name = each.value.instance_name
  bucket_name   = each.value.bucket_name
}

# output.tf
output "instances_ids" {
  value = { for k, v in module.nested : k => v.instance_id }
}

output "buckets_arns" {
  value = { for k, v in module.nested : k => v.bucket_arn }
}
