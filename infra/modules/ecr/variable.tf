variable "ecr_repo_name" {
  description = "Name of the ECR repository"
  type        = string
}

variable "scan_on_push" {
  description = "Enable the image scanning"
  type = bool
  default = true
}

variable "encryption_configuration" {
  description = "Encryption configuration to encrypt the ECR repository"
  type = string
  default = "AES256"
}

variable "tags" {
  description = "tags"
  type = map(string)
  default = null
}