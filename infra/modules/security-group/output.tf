output "alb_security_group_id" {
  description = "The ID of the created security group"
  value       = aws_security_group.main-ext-alb-sg.id
}

output "service-sg" {
  value = aws_security_group.main-int-service-sg.id
}