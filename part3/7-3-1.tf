resource "aws_autoscaling_group" "this" {
  max_size         = 5
  min_size         = 2
  desired_capacity = 4

  # 추가 매개변수들

  lifecycle {
    ignore_changes = [
      desired_capacity
    ]
  }
}
