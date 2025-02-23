variable "lb_info" {
  default = {
    name = "test-lb"
    type = "application"
  }
}

variable "listener_info" {
  default = {
    protocol    = "HTTPS"
    port        = 443
    rules       = {}
    alpn_policy = "None"
  }
}

variable "lb_type" {
  default = "application"
}

locals {
  is_alb = var.lb_info.type == "application"
  is_nlb = var.lb_info.type == "network"

  listener_rules = var.listener_info.rules
}

resource "aws_lb_listener" "this" {
  alpn_policy = var.protocol == "TLS" ? var.listener_info.alpn_policy : null

  # 매개변수 입력
}

resource "aws_lb_listener_rule" "this" {
  for_each = {
    for r in local.listener_rules : r.name => r
    if local.is_alb # ALB인 경우만 Rule 설정
  }

  # 매개변수 입력
}

check "nlb_listener_have_rule" {
  # NLB인데 Rule을 가지고 있는 경우
  assert {
    condition     = !(local.is_nlb && length(local.listener_rules) > 0)
    error_message = "NLB의 Listener는 Rule을 가질 수 없습니다. 작성된 Rule은 모두 무시됩니다."
  }
}

check "alb_listener_have_alpn_policy" {
  # ALB인데 alpn_policy를 가지고 있는 경우
  assert {
    condition     = !(local.is_alb && var.listener_info.alpn_policy != "None")
    error_message = "ALB의 Listener는 ALPN Policy를 가질 수 없습니다. 해당 ALPN Policy는 무시됩니다."
  }
}
