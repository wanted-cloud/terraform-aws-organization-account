terraform {
  required_version = ">= 1.9"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "org" {
  source = "git::https://github.com/wanted-cloud/terraform-aws-organization.git?ref=main"

  organizational_units = {
    workloads      = { name = "Workloads" }
    workloads_prod = { name = "Prod", parent = "workloads" }
  }
}

module "prod_account" {
  source = "../.."

  email                      = "aws-prod+platform@example.com"
  name                       = "Platform Prod"
  parent_id                  = module.org.organizational_units["workloads_prod"].id
  role_name                  = "PlatformAdminRole"
  iam_user_access_to_billing = "DENY"

  tags = {
    Environment = "production"
    Owner       = "platform-team"
  }
}
