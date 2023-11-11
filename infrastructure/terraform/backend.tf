terraform {
  backend "s3" {
    bucket = module.tfstate_bucket.bucket_name
    key    = "terraform.tfstate"
  }
}
