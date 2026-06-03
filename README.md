<!-- BEGIN_TF_DOCS -->
# wanted-cloud/terraform-aws-organization-account

Terraform building block managing AWS Organizations member accounts.

## Table of contents

- [Requirements](#requirements)
- [Providers](#providers)
- [Variables](#inputs)
- [Outputs](#outputs)
- [Resources](#resources)
- [Usage](#usage)
- [Importing existing resources](#importing-existing-resources)
- [Gotchas](#gotchas)
- [Contributing](#contributing)

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.9)

- <a name="requirement_aws"></a> [aws](#requirement\_aws) (~> 5.0)

## Providers

The following providers are used by this module:

- <a name="provider_aws"></a> [aws](#provider\_aws) (5.100.0)

## Required Inputs

The following input variables are required:

### <a name="input_email"></a> [email](#input\_email)

Description: Email address that becomes the root user of the new account. Must be globally unique across all AWS accounts. Plus-addressing (foo+bar@domain.com) is accepted and recommended for catch-all mailbox patterns.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: Friendly account name shown in the AWS console and Organizations API. 1-50 characters, alphanumeric plus spaces and `_.-` allowed.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_close_on_deletion"></a> [close\_on\_deletion](#input\_close\_on\_deletion)

Description: If true, `terraform destroy` attempts to CLOSE the account (triggering AWS's 90-day suspension period before final deletion). If false (default), destroy only REMOVES the account from the Organization, leaving it as a standalone account that the root user can still log into. For production accounts, leave false and close manually only when truly intended.

Type: `bool`

Default: `false`

### <a name="input_iam_user_access_to_billing"></a> [iam\_user\_access\_to\_billing](#input\_iam\_user\_access\_to\_billing)

Description: Whether IAM users in the new account can access billing information. `ALLOW` is the AWS-recommended default; `DENY` restricts billing to root user only. NOTE: this value is immutable after account creation.

Type: `string`

Default: `"ALLOW"`

### <a name="input_metadata"></a> [metadata](#input\_metadata)

Description: Metadata definitions for the module, this is optional construct allowing override of the module defaults defintions of validation expressions, error messages, resource timeouts and default tags.

Type:

```hcl
object({
    resource_timeouts = optional(
      map(
        object({
          create = optional(string, "30m")
          read   = optional(string, "5m")
          update = optional(string, "30m")
          delete = optional(string, "30m")
        })
      ), {}
    )
    tags                     = optional(map(string), {})
    validator_error_messages = optional(map(string), {})
    validator_expressions    = optional(map(string), {})
  })
```

Default: `{}`

### <a name="input_parent_id"></a> [parent\_id](#input\_parent\_id)

Description: OU id (`ou-xxxx-yyyyyyyy`) or root id (`r-xxxx`) where this account is placed. Defaults to null = root of the Organization.

Type: `string`

Default: `null`

### <a name="input_role_name"></a> [role\_name](#input\_role\_name)

Description: IAM role created in the new account that the management account can assume. Defaults to the AWS standard `OrganizationAccountAccessRole`.

Type: `string`

Default: `"OrganizationAccountAccessRole"`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: Tags applied to the account resource. Merged with module-level wanted-cloud:* tags.

Type: `map(string)`

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_arn"></a> [arn](#output\_arn)

Description: AWS account ARN.

### <a name="output_email"></a> [email](#output\_email)

Description: Root-user email of the account - pass-through from var.email.

### <a name="output_id"></a> [id](#output\_id)

Description: AWS account ID (12-digit numeric string).

### <a name="output_joined_method"></a> [joined\_method](#output\_joined\_method)

Description: How the account joined the Organization: CREATED (this module) or INVITED (added later via Organizations invite API).

### <a name="output_joined_timestamp"></a> [joined\_timestamp](#output\_joined\_timestamp)

Description: ISO-8601 timestamp at which the account joined the Organization.

### <a name="output_name"></a> [name](#output\_name)

Description: Friendly account name - pass-through from var.name.

### <a name="output_parent_id"></a> [parent\_id](#output\_parent\_id)

Description: OU id under which this account currently sits. Changes if the account is moved between OUs.

### <a name="output_role_name"></a> [role\_name](#output\_role\_name)

Description: Pass-through of the cross-account assumable role name. Downstream provider aliases use this to assume into the new account.

### <a name="output_status"></a> [status](#output\_status)

Description: Account lifecycle status: ACTIVE, SUSPENDED, or PENDING\_CLOSURE.

## Resources

The following resources are used by this module:

- [aws_organizations_account.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_account) (resource)

## Usage

> For more detailed examples navigate to `examples` folder of this repository.

Module was also published via Terraform Registry and can be used as a module from the registry.

```hcl
module "account" {
  source  = "wanted-cloud/organization-account/aws"
  version = "~> 0.1"

  email = "aws-root+shared@example.com"
  name  = "Shared Services"
}
```

### Minimal — account at org root

```hcl
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
```

### Workload — account inside an OU with tags

```hcl
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
```

## Importing existing resources

When the account already exists in the Organization (it was invited rather than created, or it predates Terraform management), import it before the first `terraform apply`:

```bash
terraform import module.account.aws_organizations_account.this 123456789012
```

The 12-digit account ID is the import key. After import, run `terraform plan` and reconcile any field drift — especially `name` casing and `parent_id`.

## Gotchas

Read these before applying in any account that matters.

| # | Gotcha | Mitigation |
|---|---|---|
| 1 | **Email is globally unique forever** — once used, even briefly, it cannot be reused for 90 days after the owning account is closed. | Standardize on plus-addressing (`prefix+role@company.com`) so each account gets a deterministic, recoverable address. |
| 2 | **`iam_user_access_to_billing` is immutable post-creation.** | `lifecycle.ignore_changes` on this field surfaces the constraint at plan time; document that changing it requires destroy + recreate (90-day cooldown). |
| 3 | **`terraform destroy` does NOT close the account by default** — it just removes the account from the Org, leaving a "standalone" account behind. | Document explicitly; recommend `close_on_deletion = false` for production and only flip to true for ephemeral/sandbox tiers. |
| 4 | **Closing an account triggers 90-day suspension** before AWS fully deletes it; the email is locked for that period. | If you set `close_on_deletion = true`, plan for the 90-day blackout window — destroy/recreate of the same account is impossible inside that window. |
| 5 | **Account creation is async** and can take 5-15 minutes per account; long parallel applies multiply this. | Set sensible Terraform timeouts (default 30m create is fine); avoid creating >5 accounts per apply if you need fast iteration — split into batches. |
| 6 | **`CreateAccount` requires `feature_set = "ALL"` on the Org** — CONSOLIDATED_BILLING orgs return AccessDenied. | Validation is upstream (T1.01 default is "ALL"); if a caller downgraded, the AWS API error will surface at apply time. |
| 7 | **Moving an account between OUs** (changing `parent_id`) is a non-destructive update — Terraform updates in place via `MoveAccount`. | Expected behaviour; no warning needed, but be aware that plans showing parent_id changes do not recreate the account. |
| 8 | **Account `name` casing changes are detected** — AWS preserves case as supplied; renaming triggers an in-place update. | Pick a casing convention (recommend Title Case for human-readable names) and stick with it. |
| 9 | **Root user credentials are unrecoverable without the email** — losing access to the inbox means losing root. | Document that the email mailbox MUST stay deliverable for the account's full lifetime. |
| 10 | **`role_name` is created in the new account at creation time only** — changing it later does NOT rename the role; it's a one-shot field. | If you need a different cross-account role name, do it at module-creation time, or create additional roles via T2.02 IAM-role module. |

## Contributing

_Contributions are welcomed and must follow [Code of Conduct](https://github.com/wanted-cloud/.github?tab=coc-ov-file) and common [Contributions guidelines](https://github.com/wanted-cloud/.github/blob/main/docs/CONTRIBUTING.md)._

> If you'd like to report security issue please follow [security guidelines](https://github.com/wanted-cloud/.github?tab=security-ov-file).
---
<sup><sub>_2025 &copy; All rights reserved - WANTED.solutions s.r.o._</sub></sup>
<!-- END_TF_DOCS -->
