resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

output "public_key" {
  value = tls_private_key.this.public_key_openssh
}

output "private_key" {
  value = tls_private_key.this.private_key_pem
}
