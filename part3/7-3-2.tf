resource "aws_appautoscaling_target" "ecs_target" {
  # ...
  lifecycle {
    replace_triggered_by = [
      aws_ecs_service.svc.id
    ]
  }
}
