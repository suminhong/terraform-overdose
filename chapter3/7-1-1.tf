resource "aws_security_group" "example" {
  name        = "example-security-group"
  description = "Security group for example usage"
  vpc_id      = aws_vpc.example.id

  # 인바운드 규칙
  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    description = "HTTP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  # 아웃바운드 규칙
  egress {
    description = "All traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # 모든 프로토콜
    cidr_blocks = ["0.0.0.0/0"]
  }
}
