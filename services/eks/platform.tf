# Platform components installed into the cluster via Helm, each with the IRSA
# role it needs. These are cluster-level add-ons from Chapters 11 to 13. They
# belong to the platform (Terraform), not to the application (the deploy
# pipeline), per the boundary discussed in Chapter 12.

# ---------------- AWS Load Balancer Controller (Chapter 11) ----------------
module "lb_controller_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name                              = "${var.cluster_name}-aws-lb-controller"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "kubernetes_service_account" "lb_controller" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.lb_controller_irsa.iam_role_arn
    }
  }
}

resource "helm_release" "aws_lb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "~> 1.7"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }
  set {
    name  = "region"
    value = var.region
  }
  set {
    name  = "vpcId"
    value = data.terraform_remote_state.vpc.outputs.vpc_id
  }
  set {
    name  = "serviceAccount.create"
    value = "false"
  }
  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  depends_on = [kubernetes_service_account.lb_controller]
}

# ---------------- metrics-server (Chapter 12, HPA dependency) ----------------
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
  version    = "~> 3.12"

  depends_on = [module.eks]
}

# ---------------- External Secrets Operator (Chapter 13) ----------------
resource "helm_release" "external_secrets" {
  name             = "external-secrets"
  repository       = "https://charts.external-secrets.io"
  chart            = "external-secrets"
  namespace        = "external-secrets"
  create_namespace = true
  version          = "~> 0.9"

  depends_on = [module.eks]
}

# IRSA role for the production SecretStore service account to read Secrets Manager.
# Annotate the production "external-secrets-sa" with the output role ARN below.
module "external_secrets_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name                             = "${var.cluster_name}-external-secrets"
  attach_external_secrets_policy        = true
  external_secrets_secrets_manager_arns = ["arn:aws:secretsmanager:${var.region}:123456789012:secret:prod/orders-api/*"]

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["production:external-secrets-sa"]
    }
  }
}

# ---------------- kube-prometheus-stack: Prometheus, Grafana, Alertmanager (Chapter 13) ----------------
resource "helm_release" "monitoring" {
  name             = "monitoring"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true
  version          = "~> 58.0"

  depends_on = [module.eks]
}

output "lb_controller_role_arn" {
  description = "IRSA role ARN for the AWS Load Balancer Controller."
  value       = module.lb_controller_irsa.iam_role_arn
}

output "external_secrets_role_arn" {
  description = "Annotate the production 'external-secrets-sa' service account with this ARN."
  value       = module.external_secrets_irsa.iam_role_arn
}
