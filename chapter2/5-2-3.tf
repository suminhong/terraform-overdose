# outputs.tf
output "bucket_seoul_id" {
  value       = aws_s3_bucket.bucket_seoul.id
  description = "서울 버킷의 아이디"
}

output "bucket_tokyo_id" {
  value       = aws_s3_bucket.bucket_tokyo.id
  description = "도쿄 버킷의 아이디"
}
