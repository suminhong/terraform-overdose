resource "aws_instance" "this" {
  for_each = {
    windows = {
      ami  = "ami-0123456789" # 윈도우용 AMI
      type = "t3.medium"
    }
    linux = {
      ami  = "ami-9876543210" # 리눅스용 AMI
      type = "r5.2xlarge"
    }
  }

  # 인스턴스별 설정
  ami           = each.value.ami
  instance_type = each.value.type

  # 공통 설정
  subnet_id              = "subnet-123456"
  vpc_security_group_ids = ["sg-12325343634"]

  tags = {
    Name = each.key
  }
}
