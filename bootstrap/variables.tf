variable "region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "Globally unique name for the Terraform state bucket."
  type        = string
  default     = "learning-terraform-state-123456789012"
}

variable "lock_table_name" {
  description = "DynamoDB table for state locking."
  type        = string
  default     = "terraform-locks"
}
