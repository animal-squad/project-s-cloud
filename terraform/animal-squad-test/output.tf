//XXX: key 값을 공유 할 수 있는 더 좋은 방법을 찾아봐야 함
output "private_key_path" {
  value     = tls_private_key.for_ec2.private_key_pem
  sensitive = true
}
