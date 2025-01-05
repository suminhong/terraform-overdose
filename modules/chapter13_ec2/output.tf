output "ec2_id" {
  description = "EC2 ID 맵"
  value = {
    for k, v in aws_instance.this : k => v.id
  }
}

output "ec2_info" {
  description = "EC2 정보 맵"
  value = {
    for k, v in aws_instance.this : k => {
      full_name         = local.ec2_set[k].full_name
      instance_id       = v.id
      private_ip        = v.private_ip
      public_ip         = try(aws_eip.this[k].public_ip, "")
      eni_id            = v.primary_network_interface_id
      availability_zone = v.availability_zone
    }
  }
}
