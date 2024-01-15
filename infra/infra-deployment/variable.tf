variable "ecr_repo_name" {
  description = "Name of the ECR repository"
  type        = string
}
variable "account_environment" {}
variable "team_name" {}
variable "availability_zones" {}
variable "image_name" {}
variable "port" {}
variable "region" {}
variable "replicas" {}
variable "task_family_name" {}