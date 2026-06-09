variable "cluster_name" {
  description = "Name of the EKS cluster."
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes version."
  type        = string
  default     = "1.31"
}

variable "project"     { type = string }
variable "environment" { type = string }
variable "owner"       { type = string }

variable "vpc_id" {
  description = "VPC the cluster runs in."
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnets for the node groups."
  type        = list(string)
}

variable "public_subnet_ids" {
  description = "Public subnets for internet-facing load balancers."
  type        = list(string)
}

variable "allowed_api_cidrs" {
  description = "CIDRs allowed to reach the public API endpoint. Tighten for production."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "node_group_instance_types" {
  type    = list(string)
  default = ["t3.medium"]
}

variable "node_group_desired_size" {
  type    = number
  default = 2
}

variable "node_group_min_size" {
  type    = number
  default = 2
}

variable "node_group_max_size" {
  type    = number
  default = 4
}
