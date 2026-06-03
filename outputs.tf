output "id" {
  description = "AWS account ID (12-digit numeric string)."
  value       = aws_organizations_account.this.id
}

output "arn" {
  description = "AWS account ARN."
  value       = aws_organizations_account.this.arn
}

output "email" {
  description = "Root-user email of the account - pass-through from var.email."
  value       = aws_organizations_account.this.email
}

output "name" {
  description = "Friendly account name - pass-through from var.name."
  value       = aws_organizations_account.this.name
}

output "parent_id" {
  description = "OU id under which this account currently sits. Changes if the account is moved between OUs."
  value       = aws_organizations_account.this.parent_id
}

output "joined_method" {
  description = "How the account joined the Organization: CREATED (this module) or INVITED (added later via Organizations invite API)."
  value       = aws_organizations_account.this.joined_method
}

output "joined_timestamp" {
  description = "ISO-8601 timestamp at which the account joined the Organization."
  value       = aws_organizations_account.this.joined_timestamp
}

output "status" {
  description = "Account lifecycle status: ACTIVE, SUSPENDED, or PENDING_CLOSURE."
  value       = aws_organizations_account.this.status
}

output "role_name" {
  description = "Pass-through of the cross-account assumable role name. Downstream provider aliases use this to assume into the new account."
  value       = aws_organizations_account.this.role_name
}
