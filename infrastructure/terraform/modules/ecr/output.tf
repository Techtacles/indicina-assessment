output "ecr_arn" {
  value = aws_ecr_repository.ecr.arn

}

output "ecr_repo_url" {
  value = aws_ecr_repository.ecr.repository_url

}

output "ecr_sha" {
  value = data.aws_ecr_image.service_image.id

}
