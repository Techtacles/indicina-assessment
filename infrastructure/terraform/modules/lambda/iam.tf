data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = var.lambda_iam_role
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}


#

data "aws_iam_policy_document" "glue_permission" {
  statement {
    effect = "Allow"

    actions = [
      "glue:*",
      "redshift:*",
      "s3:*",

    ]

    resources = ["arn:aws:glue:*:*:*","arn:aws:redshift:*:*:*","arn:aws:s3:::*"]
  }
}

resource "aws_iam_policy" "glue_redshift_pol" {
  name        = "glue_redshift_policy"
  path        = "/"
  description = "IAM policy for glue and redshift from a lambda"
  policy      = data.aws_iam_policy_document.glue_permission.json
}

resource "aws_iam_role_policy_attachment" "glue_policy_attachment" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.glue_redshift_pol.arn
}
