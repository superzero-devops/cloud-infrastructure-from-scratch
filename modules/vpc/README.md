# modules/vpc

Reusable VPC module: a `10.0.0.0/16` VPC across two AZs with `/24` public subnets
(load balancers, NAT) and `/22` private subnets (EKS nodes), an internet gateway,
one NAT gateway per AZ, an S3 gateway endpoint, and VPC flow logs.

Subnets carry the EKS discovery tags (`kubernetes.io/role/elb`,
`kubernetes.io/role/internal-elb`, `kubernetes.io/cluster/<name>`) so the cluster
and the AWS Load Balancer Controller can find them.

See Chapter 5 (design) and Chapter 6 and Chapter 8 (Terraform and modules).
