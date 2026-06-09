bucket         = "learning-terraform-state-123456789012"
key            = "eks/prod/terraform.tfstate"
region         = "us-east-1"
dynamodb_table = "terraform-locks"
encrypt        = true
