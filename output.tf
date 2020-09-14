// Azure outputs

output "private-key" {
    value = tls_private_key.velo-key.private_key_pem
}