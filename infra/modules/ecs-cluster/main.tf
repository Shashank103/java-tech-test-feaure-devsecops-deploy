resource "aws_ecs_cluster" "ecs-cluster" {
  name = format("%s-%s-ecs-cluster", var.team_name, var.account_environment)
  tags = {
    Name = format("%s-%s-ecs-cluster", var.team_name, var.account_environment)
  }
}