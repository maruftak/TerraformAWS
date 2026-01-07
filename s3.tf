# Storage service with encryption strategy (Requirement 4)

# KMS key for bucket encryption
resource "aws_kms_key" "project" {
  description         = "KMS CMK for S3 bucket ${var.project_bucket_name}"
  enable_key_rotation = true
  tags                = merge(local.tags, { Name = "coursework02-s3-kms" })
}

resource "aws_kms_alias" "project" {
  name          = "alias/coursework02-s3-kms"
  target_key_id = aws_kms_key.project.id
}

# S3 bucket
resource "aws_s3_bucket" "project" {
  bucket        = var.project_bucket_name
  force_destroy = var.s3_force_destroy
  tags          = merge(local.tags, { Name = var.project_bucket_name })
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "project" {
  bucket                  = aws_s3_bucket.project.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket ownership controls (ACLs disabled; bucket owner enforced)
resource "aws_s3_bucket_ownership_controls" "project" {
  bucket = aws_s3_bucket.project.id
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Versioning enabled
resource "aws_s3_bucket_versioning" "project" {
  bucket = aws_s3_bucket.project.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Default encryption with KMS
resource "aws_s3_bucket_server_side_encryption_configuration" "project" {
  bucket = aws_s3_bucket.project.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.project.arn
    }
    bucket_key_enabled = true
  }
}

# Bucket policy: require TLS for all requests
data "aws_iam_policy_document" "project_bucket_policy" {
  statement {
    sid     = "DenyInsecureTransport"
    effect  = "Deny"
    actions = ["s3:*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = [
      aws_s3_bucket.project.arn,
      "${aws_s3_bucket.project.arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "project" {
  bucket = aws_s3_bucket.project.id
  policy = data.aws_iam_policy_document.project_bucket_policy.json
}
