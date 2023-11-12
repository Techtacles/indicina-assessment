variable "aws_account_number" {
  type = number

}
variable "s3_zipped_lambda_bucket_name" {
  type = string

}
variable "s3_redshift_logging_bucket_name" {
  type = string

}
variable "lambda_fn_name" {
  type = string

}
variable "lambda_handler" {
  type = string

}
variable "lambda_iam_role" {
  type = string

}
variable "cluster_identifier" {
  type = string

}
variable "database_name" {
  type = string

}
variable "master_username" {
  type = string

}
variable "master_password" {
  type = string

}
variable "ecr_repo" {
  type    = string
  default = "indicina-ecr-repo"

}
