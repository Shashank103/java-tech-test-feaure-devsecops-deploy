output "vpc_id" {
  description = "The ID of the created VPC"
  value       = aws_vpc.main.id
}

output "private-subnet-1" {
  value = aws_subnet.private-subnet-1.id
}

output "private-subnet-2" {
  value = aws_subnet.private-subnet-2.id
}

output "public-subnet-1" {
  value = aws_subnet.public-subnet-1.id
}

output "public-subnet-2" {
  value = aws_subnet.public-subnet-2.id
}