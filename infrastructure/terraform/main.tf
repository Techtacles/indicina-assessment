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
        cp Dockerfile etl
        cd etl
        zip -r zipped_file.zip .
        aws s3 cp zipped_file.zip s3://${module.s3_bucket_zipped_lambda.bucket_name}/zipped_lambda/zipped_file.zip
        echo "Successfully uploaded zip file to s3"

        echo "Pushing to ecr"
        cd ../
        pwd
        ls
        aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin ${var.aws_account_number}.dkr.ecr.us-east-1.amazonaws.com
        docker build -t ${var.ecr_repo} .
        docker tag ${var.ecr_repo}:latest ${module.ecr.ecr_repo_url}:latest
        docker push ${module.ecr.ecr_repo_url}:latest
        echo "Successfully pushed to ecr"
    EOF

  }
}

data "aws_ecr_image" "service_image" {
  depends_on      = [null_resource.zip_file]
  repository_name = var.ecr_repo
  image_tag       = "latest"
}
# resource "aws_s3_object" "zip_upload" {
#   depends_on = [module.s3_bucket_zipped_lambda, null_resource.zip_file]
#   bucket     = module.s3_bucket_zipped_lambda.bucket_name
#   key        = "zipped_lambda/zipped_file.zip"
#   source     = "../../etl/zipped_file.zip"
# }

resource "aws_glue_connection" "redshift_glue_con" {
  depends_on = [module.redshift]
  name       = "redshift-glue-connection"
  connection_properties = {
    JDBC_CONNECTION_URL = "jdbc:redshift://${module.redshift.endpoint}/${module.redshift.db_name}"
    PASSWORD            = module.redshift.master_password
    USERNAME            = module.redshift.master_username
    JDBC_ENFORCE_SSL    = false
  }

}

module "lambda" {
  depends_on            = [null_resource.zip_file, module.redshift, module.ecr]
  source                = "./modules/lambda"
  s3_bucket             = module.s3_bucket_zipped_lambda.bucket_name
  s3_key                = "zipped_lambda/zipped_file.zip"
  lambda_fn_name        = var.lambda_fn_name
  lambda_handler        = var.lambda_handler
  lambda_iam_role       = var.lambda_iam_role
  glue_conn_name        = aws_glue_connection.redshift_glue_con.name
  redshift_db_name      = module.redshift.db_name
  redshift_iam_role_arn = module.redshift.redshift_iam_arn
  ecr_image_uri         = module.ecr.ecr_repo_url
  ecr_sha               = data.aws_ecr_image.service_image.id

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

module "ecr" {
  source   = "./modules/ecr"
  ecr_name = var.ecr_repo

}
