locals {
  vpc_name = var.vpc_name
  vpc_id   = var.vpc_id

  module_tag = merge(
    var.tags,
    {
      tf_module = "14_ec2"
    }
  )
}

###################################################
# Create EC2
###################################################
resource "aws_instance" "this" {
  for_each = var.ec2_set

  subnet_id              = var.subnet_id_map[each.value.subnet][each.value.az]
  ami                    = each.value.ami_id
  key_name               = each.value.ec2_key
  vpc_security_group_ids = [for sg_name in each.value.security_groups : var.sg_id_map[sg_name]]

  iam_instance_profile = each.value.ec2_role
  instance_type        = each.value.instance_type
  source_dest_check    = each.value.source_dest_check
  private_ip           = each.value.private_ip

  root_block_device {
    volume_type           = each.value.root_volume.type
    volume_size           = each.value.root_volume.size
    delete_on_termination = true

    tags = merge(
      local.module_tag,
      {
        Name    = "${var.vpc_name}-${split("-", each.value.subnet)[0]}-${each.key}-root"
        EC2     = "${var.vpc_name}-${split("-", each.value.subnet)[0]}-${each.key}"
        Env     = each.value.env
        Team    = each.value.team
        Service = each.value.service
      }
    )
  }

  tags = merge(
    local.module_tag,
    {
      Name    = "${var.vpc_name}-${split("-", each.value.subnet)[0]}-${each.key}"
      EC2     = "${var.vpc_name}-${split("-", each.value.subnet)[0]}-${each.key}"
      Env     = each.value.env
      Team    = each.value.team
      Service = each.value.service
    }
  )
}

###################################################
# Create EIP
###################################################
## Public EC2인 경우 && no_eip == false 인 경우
resource "aws_eip" "this" {
  for_each = {
    for k, v in var.ec2_set : k => v
    if split("-", v.subnet)[0] == "pub" && !v.no_eip
  }

  domain = "vpc"

  instance                  = aws_instance.this[each.key].id
  associate_with_private_ip = aws_instance.this[each.key].private_ip

  tags = merge(
    local.module_tag,
    {
      Name    = "${var.vpc_name}-${split("-", each.value.subnet)[0]}-${each.key}"
      EC2     = "${var.vpc_name}-${split("-", each.value.subnet)[0]}-${each.key}"
      Env     = each.value.env
      Team    = each.value.team
      Service = each.value.service
    }
  )
}

###################################################
# Additional EBS Volumes
###################################################
locals {
  ec2_volume_set = [
    for ec2_name, ec2_attribute in var.ec2_set : {
      for volume_set in ec2_attribute.additional_volumes : "${ec2_name}_${volume_set.device}" => merge(
        { ec2_name = ec2_name }, ec2_attribute, volume_set
      )
    }
  ]

  ec2_volume_map = tomap(module.merge_ec2_volume_set.output)
}

module "merge_ec2_volume_set" {
  source = "../utility/9_3_merge_map_in_list"
  input  = local.ec2_volume_set
}

## EBS Volume 생성
resource "aws_ebs_volume" "this" {
  for_each          = local.ec2_volume_map
  availability_zone = aws_instance.this[each.value.ec2_name].availability_zone
  size              = each.value.size
  type              = each.value.type
  iops              = startswith(each.value.type, "io") ? each.value.iops : null

  tags = merge(
    local.module_tag,
    {
      Name    = "${var.vpc_name}-${split("-", each.value.subnet)[0]}-${each.value.ec2_name}-${each.value.device}"
      EC2     = "${var.vpc_name}-${split("-", each.value.subnet)[0]}-${each.value.ec2_name}"
      Env     = each.value.env
      Team    = each.value.team
      Service = each.value.service
    }
  )
}

## EBS Volume - EC2 Instance Attach
resource "aws_volume_attachment" "this" {
  for_each    = local.ec2_volume_map
  device_name = startswith(each.value.device, "s") ? "/dev/${each.value.device}" : each.value.device
  volume_id   = aws_ebs_volume.this[each.key].id
  instance_id = aws_instance.this[each.value.ec2_name].id
}
