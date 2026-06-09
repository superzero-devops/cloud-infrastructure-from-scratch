# This module implements the Chapter 8 skeleton by wrapping the community
# terraform-aws-eks module and re-exporting a stable interface (see outputs.tf).
# It provisions the cluster, managed node groups, the OIDC provider for IRSA,
# secret encryption, control plane audit logging, and the core add-ons. See
# Chapter 11.

locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    Owner       = var.owner
    ManagedBy   = "terraform"
  }
}

module "this" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnet_ids

  # Endpoint access: public-and-private for learning, restricted to known CIDRs.
  cluster_endpoint_public_access       = true
  cluster_endpoint_public_access_cidrs = var.allowed_api_cidrs
  cluster_endpoint_private_access      = true

  # Access entries replace the old aws-auth ConfigMap.
  authentication_mode                      = "API"
  enable_cluster_creator_admin_permissions = true

  # OIDC provider for IRSA.
  enable_irsa = true

  # Envelope-encrypt Kubernetes Secrets in etcd with a KMS key.
  cluster_encryption_config = { resources = ["secrets"] }

  # Control plane logs to CloudWatch; the audit stream cannot be rebuilt later.
  cluster_enabled_log_types = ["api", "audit", "authenticator"]

  # CoreDNS, kube-proxy, and the VPC CNI as AWS-managed add-ons.
  cluster_addons = {
    coredns    = {}
    kube-proxy = {}
    vpc-cni    = {}
  }

  eks_managed_node_groups = {
    default = {
      instance_types = var.node_group_instance_types
      min_size       = var.node_group_min_size
      max_size       = var.node_group_max_size
      desired_size   = var.node_group_desired_size

      # Encrypt the node root volume.
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs         = { volume_size = 50, volume_type = "gp3", encrypted = true }
        }
      }

      # Require IMDSv2 and stop pods from reaching the node's instance metadata.
      metadata_options = {
        http_tokens                 = "required"
        http_put_response_hop_limit = 1
      }
    }
  }

  tags = local.common_tags
}
