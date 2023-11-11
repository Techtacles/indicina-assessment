terraform {
  backend "s3" {
    bucket = "indicina-de-project-tfstate-bucket"
    key    = "terraform.tfstate"
  }
}
