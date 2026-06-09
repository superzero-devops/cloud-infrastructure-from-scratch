# VPC root configuration. One state file per environment (see backends/).
# Per-environment CIDRs and NAT strategy live here as locals so the shared env
# tfvars stay small.

locals {
  vpc_cidr = {
    dev     = "10.0.0.0/16"
    staging = "10.1.0.0/16"
    prod    = "10.2.0.0/16"
  }[var.environment]

  # One NAT gateway in non-prod to save cost; one per AZ in prod for HA.
  single_nat_gateway = var.environment != "prod"
}

module "vpc" {
  source = "../../modules/vpc"

  cluster_name       = var.cluster_name
  project            = var.project
  environment        = var.environment
  owner              = var.owner
  vpc_cidr           = local.vpc_cidr
  single_nat_gateway = local.single_nat_gateway
}
