variable "email" {
  description = "Email address that becomes the root user of the new account. Must be globally unique across all AWS accounts. Plus-addressing (foo+bar@domain.com) is accepted and recommended for catch-all mailbox patterns."
  type        = string

  validation {
    condition     = can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", var.email))
    error_message = "email must be a syntactically valid email address."
  }
}

variable "name" {
  description = "Friendly account name shown in the AWS console and Organizations API. 1-50 characters, alphanumeric plus spaces and `_.-` allowed."
  type        = string

  validation {
    condition     = length(var.name) >= 1 && length(var.name) <= 50
    error_message = "name must be 1-50 characters long (AWS hard limit)."
  }

  validation {
    condition     = can(regex("^[A-Za-z0-9 ._-]+$", var.name))
    error_message = "name may only contain alphanumeric characters, spaces, and `_`, `.`, `-`."
  }
}

variable "parent_id" {
  description = "OU id (`ou-xxxx-yyyyyyyy`) or root id (`r-xxxx`) where this account is placed. Defaults to null = root of the Organization."
  type        = string
  default     = null

  validation {
    condition     = var.parent_id == null || can(regex("^(r-[a-z0-9]{4,32}|ou-[a-z0-9]{4,32}-[a-z0-9]{8,32})$", var.parent_id))
    error_message = "parent_id must be a root id (r-xxxx) or an OU id (ou-xxxx-yyyyyyyy)."
  }
}

variable "role_name" {
  description = "IAM role created in the new account that the management account can assume. Defaults to the AWS standard `OrganizationAccountAccessRole`."
  type        = string
  default     = "OrganizationAccountAccessRole"
}

variable "iam_user_access_to_billing" {
  description = "Whether IAM users in the new account can access billing information. `ALLOW` is the AWS-recommended default; `DENY` restricts billing to root user only. NOTE: this value is immutable after account creation."
  type        = string
  default     = "ALLOW"

  validation {
    condition     = contains(["ALLOW", "DENY"], var.iam_user_access_to_billing)
    error_message = "iam_user_access_to_billing must be ALLOW or DENY."
  }
}

variable "close_on_deletion" {
  description = "If true, `terraform destroy` attempts to CLOSE the account (triggering AWS's 90-day suspension period before final deletion). If false (default), destroy only REMOVES the account from the Organization, leaving it as a standalone account that the root user can still log into. For production accounts, leave false and close manually only when truly intended."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to the account resource. Merged with module-level wanted-cloud:* tags."
  type        = map(string)
  default     = {}
}
