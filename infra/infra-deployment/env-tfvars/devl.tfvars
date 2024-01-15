ecr_repo_name = "supermarket-ecr"
availability_zones = [
  "us-east-1a",
  "us-east-1b",
  "us-east-1c"
]
account_environment = "devl"
team_name           = "accolite"
image_name          = "211125330084.dkr.ecr.us-east-1.amazonaws.com/supermarket-ecr:latest"
task_family_name    = "port8080-service"
port                = "8080"
replicas            = "3"
region              = "us-east-1"