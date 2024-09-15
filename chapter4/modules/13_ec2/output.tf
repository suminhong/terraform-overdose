output "ec2_id" {
  description = "EC2 ID 맵"
  value = {
    for k, v in aws_instance.this : k => v.id
  }
}

output "ec2_private_ip" {
  description = "EC2 프라이빗 IP 맵"
  value = {
    for k, v in aws_instance.this : k => v.private_ip
  }
}

output "ec2_public_ip" {
  description = "EC2 퍼블릭 IP 맵"
  value = {
    for k, v in aws_eip.this : k => v.public_ip
  }
}
