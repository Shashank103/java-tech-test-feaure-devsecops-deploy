output "arn" {
  description = "Full ARN of the ECR Repository"
  value = aws_ecr_repository.my_ecr.arn
}

output "name" {
  description = "The name of the ECR repository"
  value = aws_ecr_repository.my_ecr.name
}

output "repository_url" {
  description = "The ULR of the repository"
  value = aws_ecr_repository.my_ecr.repository_url
}

output "repository_id" {
  description = "ID of the ECR repository"
  value = aws_ecr_repository.my_ecr.registry_id
}