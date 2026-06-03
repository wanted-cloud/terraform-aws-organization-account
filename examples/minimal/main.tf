terraform {
  required_version = ">= 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "account" {
  source = "../.."

  email = "aws-root+shared@example.com"
  name  = "Shared Services"
}
