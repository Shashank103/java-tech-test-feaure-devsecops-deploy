output "target_group_arn" {
  description = "The ARN of the created ALB target group"
  value       = aws_alb_target_group.port8080-tg-2.arn
}