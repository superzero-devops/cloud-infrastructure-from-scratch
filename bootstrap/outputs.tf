output "state_bucket" {
  description = "Name of the state bucket."
  value       = aws_s3_bucket.state.id
}

output "lock_table" {
  description = "Name of the lock table."
  value       = aws_dynamodb_table.locks.name
}

output "kms_key_arn" {
  description = "ARN of the KMS key encrypting state."
  value       = aws_kms_key.state.arn
}

output "github_oidc_provider_arn" {
  description = "ARN of the GitHub Actions OIDC provider."
  value       = aws_iam_openid_connect_provider.github.arn
}
