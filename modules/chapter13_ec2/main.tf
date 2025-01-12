locals {
  vpc_name = var.vpc_name
  vpc_id   = var.vpc_id

  module_tag = merge(
    var.tags,
    {
      tf_module = "chapter13_ec2"
    }
  )

  # ec2_set 변수 재정의
  ec2_set = {
    for k, v in var.ec2_set : k => merge(v, {
      full_name       = "${var.vpc_name}-${split("-", v.subnet)[0]}-${k}",
      instance_family = split(".", v.instance_type)[0]
    })
  }

  # EC2별로 태그를 미리 선언
  ec2_tags = {
    for k, v in local.ec2_set : k => merge(
      local.module_tag,
      {
        Name    = v.full_name
        EC2     = v.full_name
        Env     = v.env
        Team    = v.team
        Service = v.service
        OS      = upper(v.os_type)
      }
    )
  }

  # 유효성 검사를 위한 변수들
  valid_env           = ["develop", "staging", "rc", "production"]
  valid_ebs_type      = ["standard", "gp2", "gp3", "io1", "io2", "sc1", "st1"]
  valid_iops_ebs_type = ["gp3", "io1", "io2"]

  device_name_patterns = {
    linux   = "/dev/sd[fp]" # Linux 권장 볼륨 디바이스 이름
    windows = "xvd[fp]"     # Windows 권장 볼륨 디바이스 이름
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

  tags = local.ec2_tags[each.key]

  lifecycle {
    precondition { # 1. env 이름 유효성 검사
      condition     = contains(local.valid_env, each.value.env)
      error_message = "[${local.vpc_name} VPC/${each.key} EC2] env 값은 반드시 [${join(", ", local.valid_env)}] 중 하나여야 합니다."
    }

    precondition { # 2. 볼륨 타입 유효성 검사
      condition     = contains(local.valid_ebs_type, each.value.root_volume.type)
      error_message = "[${local.vpc_name} VPC/${each.key} EC2] ${each.value.root_volume.type}: 유효하지 않은 볼륨 타입입니다. root_volume.type은 반드시 [${join(", ", local.valid_ebs_type)}] 중 하나여야 합니다."
    }

    precondition { # 4. OS 타입 이름 유효성 검사
      condition     = contains(keys(local.device_name_patterns), each.value.os_type)
      error_message = "[${local.vpc_name} VPC/${each.key} EC2] ${each.value.os_type} : 유효하지 않은 운영체제 타입입니다. os_type은 반드시 [${join(", ", keys(local.device_name_patterns))}] 중 하나여야 합니다."
    }
  }
}

###################################################
# Create EIP
###################################################
# Public EC2인 경우
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
  # volume device 이름이 겹치는 경우,
  # aws_instance.this의 3번 유효성 검사로 인해 에러가 발생되므로 try처리
  ec2_volume_set = try([
    for ec2_name, ec2_attribute in local.ec2_set : {
      for volume in ec2_attribute.additional_volumes : "${ec2_name}_${volume.device}" => merge(
        { ec2_name = ec2_name }, volume, ec2_attribute
      )
    }
  ], [])

  merged_ec2_volume_set = module.merge_ec2_volume_set.output
}

module "merge_ec2_volume_set" {
  source = "../chapter9_utility/3_merge_map_in_list"
  input  = local.ec2_volume_set
}

# EBS Volume 생성
resource "aws_ebs_volume" "this" {
  for_each          = local.merged_ec2_volume_set
  availability_zone = aws_instance.this[each.value.ec2_name].availability_zone
  size              = each.value.size
  type              = each.value.type
  iops              = each.value.iops

  tags = merge(
    local.ec2_tags[each.value.ec2_name],
    {
      Name = "${each.value.full_name}-${each.value.device}"
    }
  )

  lifecycle {
    precondition { # 2. 볼륨 타입 유효성 검사
      condition     = contains(local.valid_ebs_type, each.value.type)
      error_message = "[${local.vpc_name} VPC/${each.value.full_name} EC2:${each.value.device} EBS] ${each.value.type}: 유효하지 않은 볼륨 타입입니다. additional_volumes.*.type은 반드시 [${join(", ", local.valid_ebs_type)}] 중 하나여야 합니다."
    }

    precondition { # 3. iops 타입 유효성 검사
      condition     = !(!contains(local.valid_iops_ebs_type, each.value.type) && each.value.iops != null)
      error_message = "[${local.vpc_name} VPC/${each.value.full_name} EC2:${each.value.device} EBS] iops를 지정할 수 없는 볼륨 타입입니다. iops를 해제해 주세요. iops는 [${join(", ", local.valid_iops_ebs_type)}] 타입들만 지정할 수 있습니다."
    }

    precondition { # 5. 볼륨 장치 이름 유효성 검사
      condition     = can(regex(local.device_name_patterns[each.value.os_type], each.value.device))
      error_message = "[${local.vpc_name} VPC/${each.value.ec2_name} EC2:${each.value.device} EBS] 허용하지 않는 디바이스 이름입니다. ${each.value.os_type} OS에서 사용 가능한 디바이스 이름 패턴은 ${local.device_name_patterns[lower(each.value.os_type)]} 입니다."
    }
  }
}

# EBS 볼륨 - EC2 인스턴스 연결
resource "aws_volume_attachment" "this" {
  for_each    = local.merged_ec2_volume_set
  device_name = each.value.device
  volume_id   = aws_ebs_volume.this[each.key].id
  instance_id = aws_instance.this[each.value.ec2_name].id
}
