# EKS root configuration. Reads the VPC from remote state (Chapter 7) and calls
# the EKS module (Chapter 11). The platform add-ons (AWS Load Balancer
# Controller, External Secrets Operator, metrics-server, and the monitoring
# stack) and their IRSA roles live in platform.tf.
#
# First apply on a clean account: the Kubernetes and Helm providers are
# configured from the cluster's outputs, which do not exist yet. Create the
# cluster first, then everything else:
#
#   terraform apply -target=module.eks
#   terraform apply
#
# Once the cluster exists, a normal `terraform apply` handles all of it.

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "learning-terraform-state-123456789012"
    key    = "vpc/${var.environment}/terraform.tfstate"
    region = var.region
  }
}

locals {
  # Public API access. Wide open for dev/staging learning; tightened for prod.
  allowed_api_cidrs = {
    dev     = ["0.0.0.0/0"]
    staging = ["0.0.0.0/0"]
    prod    = ["203.0.113.0/24"] # example office or VPN CIDR; replace with yours
  }[var.environment]

  node_desired = { dev = 2, staging = 2, prod = 3 }[var.environment]
}

module "eks" {
  source = "../../modules/eks"

  cluster_name = var.cluster_name
  project      = var.project
  environment  = var.environment
  owner        = var.owner

  vpc_id             = data.terraform_remote_state.vpc.outputs.vpc_id
  private_subnet_ids = data.terraform_remote_state.vpc.outputs.private_subnet_ids
  public_subnet_ids  = data.terraform_remote_state.vpc.outputs.public_subnet_ids

  allowed_api_cidrs       = local.allowed_api_cidrs
  node_group_desired_size = local.node_desired
}
