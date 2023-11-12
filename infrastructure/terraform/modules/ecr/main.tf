resource "aws_ecr_repository" "ecr" {
  name         = var.ecr_name
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}


