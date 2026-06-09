# bootstrap

Run this once per AWS account, before anything else. It uses local state to create:

- a KMS-encrypted, versioned S3 bucket for Terraform state
- a DynamoDB table for state locking
- the GitHub Actions OIDC provider for keyless CI/CD

See Chapter 7 (state backend) and Chapter 9 (OIDC provider).

```bash
terraform init
terraform apply
```

After this, every other configuration uses the S3 backend defined in `backends/`.
