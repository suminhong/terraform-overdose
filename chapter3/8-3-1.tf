resource "aws_acm_certificate" "this" {
  domain_name       = "terraform.com"
  validation_method = "DNS"

  subject_alternative_names = ["terraform.com"]
}

locals {
  acm_validate_value = tolist(aws_acm_certificate.this.domain_validation_options)[0]
}

resource "time_sleep" "wait_30_seconds" {
  depends_on = [aws_acm_certificate.this]

  create_duration = "30s"
}

check "validation_acm" {
  data "aws_acm_certificate" "this" {
    domain   = aws_acm_certificate.this.domain_name
    statuses = ["VALIDATION_TIMED_OUT", "PENDING_VALIDATION", "EXPIRED", "INACTIVE", "ISSUED", "FAILED", "REVOKED"]

    depends_on = [time_sleep.wait_30_seconds]
  }

  assert {
    condition     = data.aws_acm_certificate.this.status != "PENDING_VALIDATION"
    error_message = "다음 CNAME 레코드를 추가하세요 : ${local.acm_validate_value.resource_record_name}/${local.acm_validate_value.resource_record_value}"
  }
}
