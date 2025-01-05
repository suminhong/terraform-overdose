
locals {
  templatefiles_path      = "../templatefiles"
  resource_documents_path = "../resource_documents"
}

###################################################
# EC2 local file
###################################################
resource "local_file" "ec2" {
  content = templatefile("${local.templatefiles_path}/ec2.tftpl", {
    vpc_ec2_map = module.ec2
    region      = "ap-northeast-2"
  })
  filename = "${local.resource_documents_path}/EC2_SEOUL.md"
}
