data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["redshift.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "policy" {
  statement {
    effect    = "Allow"
    actions   = ["*"]
    resources = ["*"]
  }
}

resource "aws_iam_role" "redshift_iam_role" {
  name               = "redshift_iam_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

}
resource "aws_iam_policy" "policy" {
  name        = "redshift-policy"
  description = "A test policy"
  policy      = data.aws_iam_policy_document.policy.json
}

resource "aws_iam_role_policy_attachment" "attach-policy" {
  depends_on = [aws_iam_role.redshift_iam_role, aws_iam_policy.policy]
  role       = aws_iam_role.redshift_iam_role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_redshift_cluster_iam_roles" "associate_iam_role" {
  depends_on         = [aws_redshift_cluster.redshift_cluster]
  cluster_identifier = aws_redshift_cluster.redshift_cluster.cluster_identifier
  iam_role_arns      = [aws_iam_role.redshift_iam_role.arn]
}
