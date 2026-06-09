# A stable interface (the Chapter 8 contract), re-exported from the wrapped module.
output "cluster_name" {
  value = module.this.cluster_name
}

output "cluster_endpoint" {
  value = module.this.cluster_endpoint
}

output "cluster_ca_certificate" {
  value     = module.this.cluster_certificate_authority_data
  sensitive = true
}

output "oidc_provider_arn" {
  value = module.this.oidc_provider_arn
}

output "oidc_provider_url" {
  value = module.this.oidc_provider
}

output "node_role_arn" {
  value = module.this.eks_managed_node_groups["default"].iam_role_arn
}
