# 랜덤 비밀번호 생성
resource "random_password" "this" {
  length           = 16
  override_special = "!#$%&()*+,-.:;<=>?[]^_`{|}~"
}

locals {
  # 마스터 유저 정보
  master_username = "admin"
  master_password = random_password.this.result
}

# AWS RDS 클러스터 생성
resource "aws_rds_cluster" "this" {
  master_username = local.master_username
  master_password = local.master_password
  # (생략)
}

# 생성된 비밀번호를 AWS Secrets Manager에 저장
resource "aws_secretsmanager_secret" "this" {
  name        = "db/${local.db_name}/${local.master_username}"
  description = "Managed By Terraform"
}

resource "aws_secretsmanager_secret_version" "this" {
  secret_id = aws_secretsmanager_secret.this.id
  secret_string = jsonencode({
    "username" = local.master_username
    "password" = local.master_password
  })
}
