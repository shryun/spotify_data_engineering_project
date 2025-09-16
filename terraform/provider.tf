provider "aws" {
  region  = "us-east-1"
}

data "aws_caller_identity" "current" {} #It retrieves information about the AWS account and the IAM identity Terraform is using to make API calls