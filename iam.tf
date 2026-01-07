# IAM roles and policies for EC2 instances and team groups (least privilege)

# EC2 trust policy
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Managed policies
data "aws_iam_policy" "amazon_s3_readonly" {
  arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

data "aws_iam_policy" "ssm_managed_instance_core" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Sales EC2 role: SSM + S3 ReadOnly
resource "aws_iam_role" "sales_ec2_role" {
  name               = "SalesTeam-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_role_policy_attachment" "sales_attach_ssm" {
  role       = aws_iam_role.sales_ec2_role.name
  policy_arn = data.aws_iam_policy.ssm_managed_instance_core.arn
}

resource "aws_iam_role_policy_attachment" "sales_attach_s3_ro" {
  role       = aws_iam_role.sales_ec2_role.name
  policy_arn = data.aws_iam_policy.amazon_s3_readonly.arn
}

resource "aws_iam_instance_profile" "sales_ec2_profile" {
  name = "SalesTeam-ec2-instance-profile"
  role = aws_iam_role.sales_ec2_role.name
}

# Compliance EC2 role: SSM only (minimal)
resource "aws_iam_role" "compliance_ec2_role" {
  name               = "ComplianceTeam-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_role_policy_attachment" "compliance_attach_ssm" {
  role       = aws_iam_role.compliance_ec2_role.name
  policy_arn = data.aws_iam_policy.ssm_managed_instance_core.arn
}

resource "aws_iam_instance_profile" "compliance_ec2_profile" {
  name = "ComplianceTeam-ec2-instance-profile"
  role = aws_iam_role.compliance_ec2_role.name
}

# D-Transformation team: custom S3 read/write policy scoped to project bucket
# This is for the IAM group (human users), not EC2.

data "aws_iam_policy_document" "dtrans_s3_rw_doc" {
  statement {
    sid     = "S3RWProjectBucket"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::${var.project_bucket_name}",
      "arn:aws:s3:::${var.project_bucket_name}/*"
    ]
  }
}

resource "aws_iam_policy" "dtrans_s3_rw" {
  name   = "D-TransformationTeam-S3RW"
  policy = data.aws_iam_policy_document.dtrans_s3_rw_doc.json
}

resource "aws_iam_group_policy_attachment" "attach_dtrans_s3_rw" {
  group      = aws_iam_group.dtrans.name
  policy_arn = aws_iam_policy.dtrans_s3_rw.arn
}

# KMS usage policy for D-Transformation team to work with the bucket's CMK
data "aws_iam_policy_document" "dtrans_kms_use_doc" {
  statement {
    sid = "UseProjectKMSKey"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    resources = [aws_kms_key.project.arn]
  }
}

resource "aws_iam_policy" "dtrans_kms_use" {
  name   = "D-TransformationTeam-KMSUse"
  policy = data.aws_iam_policy_document.dtrans_kms_use_doc.json
}

resource "aws_iam_group_policy_attachment" "attach_dtrans_kms_use" {
  group      = aws_iam_group.dtrans.name
  policy_arn = aws_iam_policy.dtrans_kms_use.arn
}

# SalesTeam group: ReadOnlyAccess (broad, suitable for demo; tighten later)
data "aws_iam_policy" "readonly_access" {
  arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "attach_sales_readonly" {
  group      = aws_iam_group.sales.name
  policy_arn = data.aws_iam_policy.readonly_access.arn
}

# ComplianceTeam group: SecurityAudit (read-only access to security services)
data "aws_iam_policy" "security_audit" {
  arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

resource "aws_iam_group_policy_attachment" "attach_compliance_security_audit" {
  group      = aws_iam_group.compliance.name
  policy_arn = data.aws_iam_policy.security_audit.arn
}

# DevOpsTeam group: EC2 ReadOnly + AutoScaling FullAccess (focused ops)
data "aws_iam_policy" "ec2_readonly" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ReadOnlyAccess"
}

data "aws_iam_policy" "autoscaling_full" {
  arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
}

resource "aws_iam_group_policy_attachment" "attach_devops_ec2_ro" {
  group      = aws_iam_group.devops.name
  policy_arn = data.aws_iam_policy.ec2_readonly.arn
}

resource "aws_iam_group_policy_attachment" "attach_devops_as_full" {
  group      = aws_iam_group.devops.name
  policy_arn = data.aws_iam_policy.autoscaling_full.arn
}

# RedTeam group: no policies by default (principle of least privilege; enable per engagement)

# AdministrativeTeam group: IAM ReadOnly + Billing ReadOnly

data "aws_iam_policy" "iam_readonly" {
  arn = "arn:aws:iam::aws:policy/IAMReadOnlyAccess"
}

data "aws_iam_policy" "billing_readonly" {
  arn = "arn:aws:iam::aws:policy/AWSBillingReadOnlyAccess"
}

resource "aws_iam_group_policy_attachment" "attach_admin_iam_ro" {
  group      = aws_iam_group.admin.name
  policy_arn = data.aws_iam_policy.iam_readonly.arn
}

resource "aws_iam_group_policy_attachment" "attach_admin_billing_ro" {
  group      = aws_iam_group.admin.name
  policy_arn = data.aws_iam_policy.billing_readonly.arn
}

# ------------------------------------------------------------
# MFA enforcement and self-service enrollment for ALL groups
# ------------------------------------------------------------

# Deny all actions if request is not MFA-authenticated, except actions required to set up MFA or obtain session tokens.
data "aws_iam_policy_document" "deny_without_mfa_doc" {
  statement {
    sid     = "DenyAllExceptListedIfNoMFA"
    effect  = "Deny"
    # Allow only the minimum set of actions that let a user enroll or manage MFA and get a session token
    not_actions = [
      "iam:CreateVirtualMFADevice",
      "iam:EnableMFADevice",
      "iam:ListMFADevices",
      "iam:ListVirtualMFADevices",
      "iam:ResyncMFADevice",
      "iam:DeactivateMFADevice",
      "iam:GetUser",
      "iam:ListUsers",
      "iam:ChangePassword",
      "iam:GetAccountPasswordPolicy",
      "iam:GetAccountSummary",
      "iam:ListAccountAliases",
      "sts:GetSessionToken",
      "sts:AssumeRole"
    ]
    resources = ["*"]
    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["false"]
    }
  }
}

resource "aws_iam_policy" "deny_without_mfa" {
  name   = "DenyRequestsWithoutMFA"
  policy = data.aws_iam_policy_document.deny_without_mfa_doc.json
}

# Allow users to manage their own MFA device and password (scoped to their own username)
data "aws_iam_policy_document" "allow_manage_own_mfa_doc" {
  statement {
    sid    = "AllowListMFADevices"
    effect = "Allow"
    actions = [
      "iam:ListMFADevices",
      "iam:ListVirtualMFADevices",
      "iam:GetAccountPasswordPolicy",
      "iam:GetAccountSummary",
      "iam:ListAccountAliases"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowCreateOwnVirtualMFADevice"
    effect = "Allow"
    actions = [
      "iam:CreateVirtualMFADevice"
    ]
    resources = [
      "arn:aws:iam::*:mfa/$${aws:username}"
    ]
  }

  statement {
    sid    = "AllowManageOwnMFADevice"
    effect = "Allow"
    actions = [
      "iam:EnableMFADevice",
      "iam:DeactivateMFADevice",
      "iam:ResyncMFADevice",
      "iam:ListMFADevices",
      "iam:GetUser"
    ]
    resources = [
      "arn:aws:iam::*:user/$${aws:username}"
    ]
  }

  statement {
    sid    = "AllowChangeOwnPassword"
    effect = "Allow"
    actions = [
      "iam:ChangePassword"
    ]
    resources = [
      "arn:aws:iam::*:user/$${aws:username}"
    ]
  }
}

resource "aws_iam_policy" "allow_manage_own_mfa" {
  name   = "AllowUsersManageOwnMFA"
  policy = data.aws_iam_policy_document.allow_manage_own_mfa_doc.json
}

# Attach MFA policies to all IAM groups
resource "aws_iam_group_policy_attachment" "attach_devops_deny_without_mfa" {
  group      = aws_iam_group.devops.name
  policy_arn = aws_iam_policy.deny_without_mfa.arn
}

resource "aws_iam_group_policy_attachment" "attach_devops_allow_manage_own_mfa" {
  group      = aws_iam_group.devops.name
  policy_arn = aws_iam_policy.allow_manage_own_mfa.arn
}

resource "aws_iam_group_policy_attachment" "attach_compliance_deny_without_mfa" {
  group      = aws_iam_group.compliance.name
  policy_arn = aws_iam_policy.deny_without_mfa.arn
}

resource "aws_iam_group_policy_attachment" "attach_compliance_allow_manage_own_mfa" {
  group      = aws_iam_group.compliance.name
  policy_arn = aws_iam_policy.allow_manage_own_mfa.arn
}

resource "aws_iam_group_policy_attachment" "attach_sales_deny_without_mfa" {
  group      = aws_iam_group.sales.name
  policy_arn = aws_iam_policy.deny_without_mfa.arn
}

resource "aws_iam_group_policy_attachment" "attach_sales_allow_manage_own_mfa" {
  group      = aws_iam_group.sales.name
  policy_arn = aws_iam_policy.allow_manage_own_mfa.arn
}

resource "aws_iam_group_policy_attachment" "attach_dtrans_deny_without_mfa" {
  group      = aws_iam_group.dtrans.name
  policy_arn = aws_iam_policy.deny_without_mfa.arn
}

resource "aws_iam_group_policy_attachment" "attach_dtrans_allow_manage_own_mfa" {
  group      = aws_iam_group.dtrans.name
  policy_arn = aws_iam_policy.allow_manage_own_mfa.arn
}

resource "aws_iam_group_policy_attachment" "attach_admin_deny_without_mfa" {
  group      = aws_iam_group.admin.name
  policy_arn = aws_iam_policy.deny_without_mfa.arn
}

resource "aws_iam_group_policy_attachment" "attach_admin_allow_manage_own_mfa" {
  group      = aws_iam_group.admin.name
  policy_arn = aws_iam_policy.allow_manage_own_mfa.arn
}

resource "aws_iam_group_policy_attachment" "attach_red_deny_without_mfa" {
  group      = aws_iam_group.red.name
  policy_arn = aws_iam_policy.deny_without_mfa.arn
}

resource "aws_iam_group_policy_attachment" "attach_red_allow_manage_own_mfa" {
  group      = aws_iam_group.red.name
  policy_arn = aws_iam_policy.allow_manage_own_mfa.arn
}
