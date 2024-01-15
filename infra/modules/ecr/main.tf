resource "aws_ecr_repository" "my_ecr" {
  name                 = var.ecr_repo_name

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  encryption_configuration {
    encryption_type = var.encryption_configuration
  }
}