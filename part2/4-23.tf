resource "aws_db_instance" "rds" {
  identifier        = "example-cluster"
  db_name           = "example"
  allocated_storage = 20
  storage_type      = "gp3"
  engine            = "postgres"
  engine_version    = "16.3"
  instance_class    = "db.t3.micro"
  username          = "example"
  password          = var.db_password
}

variable "db_password" {
  type        = string
  description = "데이터베이스 비밀번호"
}
