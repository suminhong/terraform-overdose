# 리소스 블럭 사용 예시 - 기본 프로바이더 사용
resource "aws_instance" "this" {
  provider      = aws # 생략 가능
  instance_type = "t3.medium"
}

# 리소스 블럭 사용 예시 - 추가 프로바이더 사용
resource "aws_instance" "this" {
  provider      = aws.terraform-b # 프로바이더의 앨리어스를 명시
  instance_type = "t3.medium"
}

# 모듈 블럭 사용 예시 - 기본 프로바이더 사용
module "my_module" {
  source = "./modules/my_module"
  providers = { # 생략 가능
    aws = aws
  }
}

# 모듈 블럭 사용 예시 - 추가 프로바이더 사용
module "my_module" {
  source = "./modules/my_module"
  providers = {
    aws = aws.terraform-b # 프로바이더의 앨리어스를 명시
  }
}
