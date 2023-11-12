module "s3_bucket_zipped_lambda" {
  source      = "./modules/s3"
  bucket_name = var.s3_zipped_lambda_bucket_name


}
module "s3_redshift_logging" {
  source      = "./modules/s3"
  bucket_name = var.s3_redshift_logging_bucket_name


}

resource "null_resource" "zip_file" {
  triggers = {
    always = timestamp()
  }
  provisioner "local-exec" {
    command = <<EOF
        cd ../../
        cp -r data etl
        cd etl
        pip install -r requirements.txt -t .
        zip -r zipped_file.zip .
        ls
        pwd

    EOF

  }
}

resource "aws_s3_object" "zip_upload" {
  depends_on = [module.s3_bucket_zipped_lambda, null_resource.zip_file]
  bucket     = module.s3_bucket_zipped_lambda.bucket_name
  key        = "zipped_lambda/zipped_file.zip"
  source     = "zipped_file.zip"
}

resource "aws_glue_connection" "redshift_glue_con" {
  depends_on = [module.redshift]
  name       = "redshift-glue-connection"
  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:redshift://${module.redshift.endpoint}:${module.redshift.redshift_port}/${module.redshift.db_name}"
    PASSWORD            = module.redshift.master_password
    USERNAME            = module.redshift.master_username
    JDBC_ENFORCE_SSL    = false
  }

}

module "lambda" {
  depends_on            = [aws_s3_object.zip_upload, module.redshift]
  source                = "./modules/lambda"
  s3_bucket             = aws_s3_object.zip_upload.bucket
  s3_key                = aws_s3_object.zip_upload.key
  lambda_fn_name        = var.lambda_fn_name
  lambda_handler        = var.lambda_handler
  lambda_iam_role       = var.lambda_iam_role
  glue_conn_name        = aws_glue_connection.redshift_glue_con.name
  redshift_db_name      = module.redshift.db_name
  redshift_iam_role_arn = module.redshift.redshift_iam_arn

}

module "redshift" {
  depends_on          = [module.s3_redshift_logging]
  source              = "./modules/redshift"
  cluster_identifier  = var.cluster_identifier
  database_name       = var.database_name
  master_username     = var.master_username
  master_password     = var.master_password
  logging_bucket_name = module.s3_redshift_logging.bucket_name


}
