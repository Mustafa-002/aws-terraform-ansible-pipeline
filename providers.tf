terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.80.0"
    }
  }

  backend "s3" {
    bucket = "bucket-for-devops-labs"
    key    = "iac-lab/terraform.tfstate"
    region = "us-east-1" # Ensure this matches the region where the bucket was created
  }
}
