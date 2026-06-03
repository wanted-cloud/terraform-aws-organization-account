/*
 * # wanted-cloud/terraform-aws-organization-account
 *
 * Terraform building block managing AWS Organizations member accounts.
 */

resource "aws_organizations_account" "this" {
  name                       = var.name
  email                      = var.email
  parent_id                  = var.parent_id
  role_name                  = var.role_name
  iam_user_access_to_billing = var.iam_user_access_to_billing
  close_on_deletion          = var.close_on_deletion

  tags = merge(local.metadata.tags, var.tags)

  lifecycle {
    # AWS does not allow changing iam_user_access_to_billing after creation.
    # Surface the constraint at plan time instead of letting AWS fail the apply.
    ignore_changes = [iam_user_access_to_billing]
  }
}
