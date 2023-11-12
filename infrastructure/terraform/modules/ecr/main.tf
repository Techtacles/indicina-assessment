resource "aws_ecr_repository" "ecr" {
  name         = var.ecr_name
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

data "aws_ecr_image" "service_image" {
  repository_name = var.ecr_name
  image_tag       = "latest"
}
