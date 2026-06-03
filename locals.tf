locals {
  // Here you can define module metadata
  definitions = {
    tags = {
      ManagedBy             = "Terraform"
      "wanted-cloud:module" = "terraform-aws-organization-account"
      "wanted-cloud:tier"   = "T1.02"
    }
  }
}
