data "dns_a_record_set" "google" {
  host = "google.com"
}

output "google_record_addresses" {
  value = data.dns_a_record_set.google.addrs
}
