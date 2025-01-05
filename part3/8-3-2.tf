check "validation_record" {
  data "dns_cname_record_set" "validation" {
    host = local.acm_validate_value.resource_record_name

    depends_on = [time_sleep.wait_30_seconds]
  }

  assert {
    condition     = data.dns_cname_record_set.validation.cname == local.acm_validate_value.resource_record_value
    error_message = "다음 CNAME 레코드를 추가하세요 : ${local.acm_validate_value.resource_record_name}/${local.acm_validate_value.resource_record_value}"
  }
}
