output "iam_role_arn" {
  description = "The ARN of the created IAM role"
  value       = aws_iam_role.ecs_task_execution_role.arn
}