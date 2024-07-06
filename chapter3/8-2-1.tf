data "aws_ami" "this" {
  owners = ["amazon"]

  filter {
    name   = "image-id"
    values = ["ami-06f37ad9b29fcbdc3"]
  }
}

resource "aws_instance" "x86_64" {
  ami           = data.aws_ami.this.id
  instance_type = "t3.medium"
  # 추가 매개변수

  lifecycle {
    precondition {
      condition     = data.aws_ami.this.architecture == "x86_64"
      error_message = "x86_64 아키텍처 AMI ID를 입력해 주세요."
    }

    postcondition {
      condition     = self.public_dns != ""
      error_message = "Public DNS가 생성되지 않았습니다."
    }
  }
}
