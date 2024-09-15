# 이미지 정보 불러오기
data "aws_ami" "this" {
  for_each = var.ec2_set

  filter {
    name   = "image-id"
    values = [each.value.ami_id]
  }
}

locals {
  vpc_name = var.vpc_name
  vpc_id   = var.vpc_id

  module_tag = merge(
    var.tags,
    {
      tf_module = "13_ec2"
    }
  )

  # ec2_set 변수 재정의
  ec2_set = {
    for k, v in var.ec2_set : k => merge(v, {
      instance_family = split(".", v.instance_type)[0]
      full_name       = "${var.vpc_name}-${split("-", v.subnet)[0]}-${k}",
    })
  }

  # EC2별 태그 선정의
  ec2_tags = {
    for k, v in local.ec2_set : k => merge(
      local.module_tag,
      {
        Name    = v.full_name
        EC2     = v.full_name
        Env     = v.env
        Team    = v.team
        Service = v.service
      }
    )
  }

  # AMI별 루트 볼륨 사이즈 계산
  ami_root_volume_size = {
    for k, v in data.aws_ami.this : k => [
      for device in v.block_device_mappings : device.ebs.volume_size
      if device.device_name == v.root_device_name
    ][0]
  }
}

###################################################
# Create EC2
###################################################
resource "aws_instance" "this" {
  for_each = local.ec2_set

  subnet_id              = var.subnet_id_map[each.value.subnet][each.value.az]
  ami                    = each.value.ami_id
  key_name               = each.value.ec2_key
  vpc_security_group_ids = [for sg_name in each.value.security_groups : var.sg_id_map[sg_name]]

  iam_instance_profile = each.value.ec2_role
  instance_type        = each.value.instance_type
  private_ip           = each.value.private_ip

  root_block_device {
    volume_type           = each.value.root_volume.type
    volume_size           = each.value.root_volume.size
    delete_on_termination = true

    tags = merge(
      local.ec2_tags[each.key],
      {
        Name = "${each.value.full_name}-root"
      }
    )
  }

  tags = merge(
    local.ec2_tags[each.key],
    {
      Image_Arch     = data.aws_ami.this[each.key].architecture
      Image_Name     = data.aws_ami.this[each.key].name
      Image_Platform = data.aws_ami.this[each.key].platform == "" ? "Linux" : data.aws_ami.this[each.key].platform
    }
  )

  lifecycle {
    precondition { # x86_64 이미지를 그래비톤 인스턴스로 설정할 수 없음.
      condition     = !(startswith(data.aws_ami.this[each.key].architecture, "x86") && strcontains(each.value.instance_family, "g"))
      error_message = "[${local.vpc_name} VPC/${each.key} EC2] x86 아키텍처 이미지는 그래비톤 타입으로 실행할 수 없습니다. (현재 선택된 인스턴스 패밀리 : ${each.value.instance_family})"
    }

    precondition { # arm64 이미지는 그래비톤 인스턴스로만 설정할 수 있음.
      condition     = !(startswith(data.aws_ami.this[each.key].architecture, "arm") && !strcontains(each.value.instance_family, "g"))
      error_message = "[${local.vpc_name} VPC/${each.key} EC2] arm 아키텍처 이미지는 그래비톤 타입으로만 실행할 수 있습니다. (현재 선택된 인스턴스 패밀리 : ${each.value.instance_family})"
    }

    precondition { # 입력된 루트 볼륨 사이즈는 이미지에 지정된 루트 볼륨 사이즈 이상이어야 함.
      condition     = each.value.root_volume.size >= local.ami_root_volume_size[each.key]
      error_message = "[${local.vpc_name} VPC/${each.key} EC2] 루트 볼륨 사이즈는 ${local.ami_root_volume_size[each.key]} 이상이어야 합니다."
    }
  }
}

###################################################
# Create EIP
###################################################
## Public EC2인 경우
resource "aws_eip" "this" {
  for_each = {
    for k, v in local.ec2_set : k => v
    if split("-", v.subnet)[0] == "pub"
  }

  domain = "vpc"

  instance                  = aws_instance.this[each.key].id
  associate_with_private_ip = aws_instance.this[each.key].private_ip

  tags = local.ec2_tags[each.key]
}

###################################################
# Additional EBS Volumes
###################################################
locals {
  ec2_volume_set = [
    for ec2_name, ec2_attribute in local.ec2_set : {
      for volume in ec2_attribute.additional_volumes : "${ec2_name}_${volume.device}" => merge(
        volume, {
          ec2_name  = ec2_name,
          full_name = ec2_attribute.full_name
        },
      )
    }
  ]

  merged_ec2_volume_set = module.merge_ec2_volume_set.output
}

module "merge_ec2_volume_set" {
  source = "../utility/9_3_merge_map_in_list"
  input  = local.ec2_volume_set
}

## EBS Volume 생성
resource "aws_ebs_volume" "this" {
  for_each          = local.merged_ec2_volume_set
  availability_zone = aws_instance.this[each.value.ec2_name].availability_zone
  size              = each.value.size
  type              = each.value.type
  iops              = startswith(each.value.type, "io") ? each.value.iops : null

  tags = merge(
    local.ec2_tags[each.value.ec2_name],
    {
      Name = "${each.value.full_name}-${each.value.device}"
    }
  )
}

## EBS Volume - EC2 Instance Attach
resource "aws_volume_attachment" "this" {
  for_each    = local.merged_ec2_volume_set
  device_name = startswith(each.value.device, "s") ? "/dev/${each.value.device}" : each.value.device
  volume_id   = aws_ebs_volume.this[each.key].id
  instance_id = aws_instance.this[each.value.ec2_name].id
}
