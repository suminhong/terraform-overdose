# 코드 15-6
resource "terraform_data" "reset_user_password" {
  for_each = local.ad_users


  provisioner "local-exec" {
    command = <<EOT
aws ds reset-user-password --directory-id ${local.ds_id} --user-name ${each.key} --new-password ${local.init_password} --profile ${local.aws_profile}
EOT
  }
}

# 코드 15-7
resource "aws_instance" "resource_a" {
  ami           = "ami-045f2d6eeb07ce8c0"
  instance_type = "t3.micro"
}

resource "terraform_data" "delay" {
  provisioner "local-exec" {
    command = "sleep 30"
  }

  depends_on = [aws_instance.resource_a]
}

resource "aws_instance" "resource_b" {
  ami           = "ami-045f2d6eeb07ce8c0"
  instance_type = "t3.micro"


  depends_on = [null_resource.delay]
}
