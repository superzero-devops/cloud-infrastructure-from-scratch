# modules/eks

Implements the Chapter 8 EKS module skeleton by wrapping the community
`terraform-aws-modules/eks/aws` module and re-exporting a stable interface
(`oidc_provider_arn`, `oidc_provider_url`, `cluster_endpoint`,
`cluster_ca_certificate`, ...). The wrapper provisions the cluster, managed node
groups (hardened with IMDSv2 and encrypted volumes), the OIDC provider for IRSA,
secret encryption, control plane audit logging, and the core add-ons.

See Chapter 8 (interface) and Chapter 11 (implementation).
