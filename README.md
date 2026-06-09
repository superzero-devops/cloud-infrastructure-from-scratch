# Cloud Infrastructure from Scratch: Companion Code

Working code for the book **Cloud Infrastructure from Scratch: Kubernetes, Terraform, and AWS for Career Switchers** by Raymond Trinidad.

This repository builds the full stack from the book: a custom VPC, an EKS cluster provisioned with Terraform, a hardened application deployed with Helm, secured with RBAC and network policies, shipped by CI/CD, and watched by Prometheus and Grafana.

> You do not need to type this code out by hand. Read it alongside the chapters. Every file maps to a chapter so you can see the idea and the implementation together.

## Conventions used throughout

| Thing | Value |
|-------|-------|
| AWS account placeholder | `123456789012` |
| Region | `us-east-1` |
| State bucket | `learning-terraform-state-123456789012` |
| State lock table | `terraform-locks` |
| State key convention | `<service>/<environment>/terraform.tfstate` |
| Cluster name | `learning-<env>` (learning-dev, learning-staging, learning-prod) |
| Sample app | `orders-api` in the `production` namespace |

Replace `123456789012` and the bucket name with your own before applying anything.

## Repository layout

```
.
├── bootstrap/        One-time: state backend (S3 + DynamoDB + KMS) and GitHub OIDC provider   (Ch 7, 9)
├── modules/
│   ├── vpc/          Reusable VPC module                                                       (Ch 6, 8)
│   └── eks/          EKS module wrapping the community terraform-aws-eks module                (Ch 8, 11)
├── services/
│   ├── vpc/          VPC root configuration, one state per environment                         (Ch 9)
│   └── eks/          EKS root configuration; reads VPC via remote state                        (Ch 9, 11)
├── envs/             Per-environment variables (dev, staging, prod)                            (Ch 9)
├── backends/         Per-environment backend configs                                           (Ch 7, 9)
├── charts/
│   └── orders-api/   Helm chart for the sample application                                     (Ch 12)
├── k8s/              Namespace + PSS, RBAC, NetworkPolicies, ExternalSecret, ServiceMonitor,
│                     and the ALB Ingress                                                       (Ch 10, 13)
├── app/              The sample orders-api application and its Dockerfile                      (Ch 14)
└── .github/workflows/  Terraform plan/apply, drift detection, and app deploy pipelines         (Ch 9, 14)
```

## Order of operations

1. `bootstrap/` once per account (state backend + OIDC).                 See Chapter 7 and Chapter 9.
2. `services/vpc/` per environment.                                       See Chapter 6 and Chapter 9.
3. `services/eks/` per environment (reads the VPC from remote state).     See Chapter 11.
4. Platform add-ons in `services/eks/platform.tf` (load balancer controller with its IRSA role, External Secrets Operator, metrics-server, and the kube-prometheus monitoring stack) come up with the cluster. See Chapter 11 to 13.
5. Deploy the app: `helm upgrade --install orders-api ./charts/orders-api ...`   See Chapter 12.
6. Apply `k8s/` security and observability manifests.                     See Chapter 13.

On a clean account, the very first `services/eks` apply needs the cluster to exist before the Kubernetes and Helm providers can configure themselves, so run it in two steps the first time (shown below). After that, a normal `terraform apply` handles everything.

## Quick start (dev)

```bash
# 1. one-time backend + OIDC
cd bootstrap && terraform init && terraform apply

# 2. network
cd ../services/vpc
terraform init -backend-config=../../backends/vpc-dev.hcl
terraform apply -var-file=../../envs/dev.tfvars

# 3. cluster (first apply is two steps: cluste