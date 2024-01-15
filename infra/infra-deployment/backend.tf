terraform {
  backend "s3" {
    bucket         = "accolite-terraform-state-bucket"
    key            = "accolite/tfstate/terraform.tfstate"
    region         = "us-east-1" # Use your desired AWS region
    encrypt        = true
    dynamodb_table = "terraform_locks" # Optional: Enables locking using DynamoDB
  }
}
