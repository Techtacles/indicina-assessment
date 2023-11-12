resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = var.logging_bucket_name
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}

data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.redshift_iam_role.arn]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
      "s3:GetBucketAcl",
      "s3:PutBucketPolicy"
    ]

    resources = [
      "*"
    ]
  }
}
