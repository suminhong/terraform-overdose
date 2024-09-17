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
      full_name       = "${var.vpc_name}-${split("-", v.subnet)[0]}-${k}",
      image_arch      = data.aws_ami.this[k].architecture
      image_name      = data.aws_ami.this[k].name
      image_platform  = data.aws_ami.this[k].platform == "" ? "linux" : data.aws_ami.this[k].platform
      instance_family = split(".", v.instance_type)[0]
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

  # required - 반드시 들어가야 하는 값들
  ami                    = each.value.ami_id
  instance_type          = each.value.instance_type
  subnet_id              = var.subnet_id_map[each.value.subnet][each.value.az]
  vpc_security_group_ids = [for sg_name in each.value.security_groups : var.sg_id_map[sg_name]]

  # optional - 입력 안할 시 null값이 들어감
  iam_instance_profile = each.value.ec2_role
  key_name             = each.value.ec2_key
  private_ip           = each.value.private_ip

  # 루트 볼륨 설정
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
      Image_Arch     = each.value.image_arch
      Image_Name     = each.value.image_name
      Image_Platform = each.value.image_platform
    }
  )

  lifecycle {
    precondition { # 1. env 값이 develop, staging, rc, production 중 하나인가?
      condition     = contains(["develop", "staging", "rc", "production"], each.value.env)
      error_message = "[${local.vpc_name} VPC/${each.key} EC2] env 값은 반드시 [develop, staging, rc, production] 중 하나여야 합니다."
    }

    precondition { # 2. x86 아키텍처 이미지를 그래비톤 인스턴스로 설정할 수 없음.
      condition     = !(startswith(each.value.image_arch, "x86") && strcontains(each.value.instance_family, "g"))
      error_message = "[${local.vpc_name} VPC/${each.key} EC2] x86 아키텍처 이미지는 그래비톤 타입으로 실행할 수 없습니다. (현재 선택된 인스턴스 패밀리 : ${each.value.instance_family})"
    }

    precondition { # 3. arm 아키텍처 이미지는 그래비톤 인스턴스로만 설정할 수 있음.
      condition     = !(startswith(each.value.image_arch, "arm") && !strcontains(each.value.instance_family, "g"))
      error_message = "[${local.vpc_name} VPC/${each.key} EC2] arm 아키텍처 이미지는 그래비톤 타입으로만 실행할 수 있습니다. (현재 선택된 인스턴스 패밀리 : ${each.value.instance_family})"
    }

    precondition { # 4. 입력된 루트 볼륨 사이즈는 이미지에 지정된 루트 볼륨 사이즈 이상이어야 함.
      condition     = each.value.root_volume.size >= local.ami_root_volume_size[each.key]
      error_message = "[${local.vpc_name} VPC/${each.key} EC2] 루트 볼륨 사이즈는 ${local.ami_root_volume_size[each.key]} 이상이어야 합니다."
    }

    precondition { # 5. 루트 볼륨 타입 유효성 검사
      condition     = contains(local.available_ebs_type, each.value.root_volume.type)
      error_message = "[${local.vpc_name} VPC/${each.key} EC2] root볼륨: 유효하지 않은 볼륨 타입입니다. 사용 가능한 타입 : [${join(", ", local.available_ebs_type)}]"
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
        { ec2_name = ec2_name }, volume, ec2_attribute
      )
    }
  ]

  merged_ec2_volume_set = module.merge_ec2_volume_set.output

  available_ebs_type = ["standard", "gp2", "gp3", "io1", "io2", "sc1", "st1"]
  valid_iops_type    = ["gp3", "io1", "io2"]

  device_name_patterns = {
    linux   = "/dev/sd[fp]" # Linux 권장 볼륨 디바이스 이름
    windows = "xvd[fp]"     # Windows 권장 볼륨 디바이스 이름
  }
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
  iops              = contains(local.valid_iops_type, each.value.type) ? each.value.iops : null

  tags = merge(
    local.ec2_tags[each.value.ec2_name],
    {
      Name = "${each.value.full_name}-${each.value.device}"
    }
  )

  lifecycle {
    precondition { # 5. 추가 볼륨 타입 유효성 검사
      condition     = contains(local.available_ebs_type, each.value.type)
      error_message = "[${local.vpc_name} VPC/${each.value.ec2_name} EC2] ${each.value.device}: 유효하지 않은 볼륨 타입입니다. 사용 가능한 타입 : [${join(", ", local.available_ebs_type)}]"
    }

    precondition { # 6. 볼륨 디바이스 이름 유효성 검사
      condition     = can(regex(local.device_name_patterns[each.value.image_platform], each.value.device))
      error_message = "[${local.vpc_name} VPC/${each.value.ec2_name} EC2] ${each.value.device}: 유효하지 않은 디바이스 이름입니다. ${each.value.image_platform} OS에서 권장되는 디바이스 이름 패턴은 ${local.device_name_patterns[lower(each.value.image_platform)]} 입니다."
    }
  }
}

## EBS Volume - EC2 Instance Attach
resource "aws_volume_attachment" "this" {
  for_each    = local.merged_ec2_volume_set
  device_name = each.value.device
  volume_id   = aws_ebs_volume.this[each.key].id
  instance_id = aws_instance.this[each.value.ec2_name].id
}
