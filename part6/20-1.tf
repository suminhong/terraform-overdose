resource "aws_security_group" "example_sg" {
  name        = "manually-created-sg"
  description = "수동으로 만든 보안그룹"
  vpc_id      = "vpc-example"
}

resource "aws_security_group_rule" "example_sg_rule" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.example_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}
