resource "aws_db_instance" "example" {
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = "mydatabase"
  username             = "admin"
  password             = "password"
  parameter_group_name = "default.mysql8.0"
  db_subnet_group_name = "db-subnet-group"
  skip_final_snapshot  = true
}
