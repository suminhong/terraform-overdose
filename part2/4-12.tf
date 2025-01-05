locals {
  server_map = {
    ad_server = {
      active    = true
      is_window = true
    }
    squid_proxy = {
      active    = false
      is_window = false
    }
    web_server = {
      active    = true
      is_window = false
    }
  }

  active_server = [
    for k, v in local.server_map : k
    if v.active
  ]

  linux_server = {
    for k, v in local.server_map : k => v
    if !v.is_window
  }
}
