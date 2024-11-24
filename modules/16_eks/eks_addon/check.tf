check "addon_versions" {
  ## 현재 Default Version과 달라지는 경우 WARNING 문구 발생
  assert {
    condition     = local.addon_default_version == local.addon_version
    error_message = "[${upper(local.cluster_name)}(${local.cluster_version})] 클러스터의 ${upper(var.name)} 권장 버전은 ${local.addon_default_version} 입니다."
  }
}
