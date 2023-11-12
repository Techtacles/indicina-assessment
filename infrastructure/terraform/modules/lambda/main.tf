resource "aws_lambda_function" "lambda_fn" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  function_name = var.lambda_fn_name
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = var.lambda_handler
  image_uri     = "${var.ecr_image_uri}@${var.ecr_sha}"
  package_type  = "Image"
  timeout       = 600

  #source_code_hash = data.archive_file.lambda.output_base64sha256

  runtime = "python3.9"
  environment {
    variables = {
      S3_BUCKET_NAME    = var.s3_bucket
      GLUE_CONNECTION   = var.glue_conn_name
      REDSHIFT_DB_NAME  = var.redshift_db_name
      REDSHIFT_IAM_ROLE = var.redshift_iam_role_arn
    }
  }

}
