resource "aws_cloudwatch_log_group" "main" {
  name = format("/ecs/%s/%s/%s", var.team_name,var.account_environment,var.task_family_name)
}

#Defining template file
data "template_file" "task_def" {
  template = file("${path.module}/task-definition/service.json")
  vars = {
    image_name = var.image_name
    task_family_name = var.task_family_name
    port = var.port
    region = var.region
    log_group = aws_cloudwatch_log_group.main.name
  }
}

#ECS Task Definition
resource "aws_ecs_task_definition" "ecs_task_def" {
  family                   = format("ecs-%s-%s-%s",var.team_name, var.account_environment, var.task_family_name)
  container_definitions    = data.template_file.task_def.rendered
  execution_role_arn       = var.ecs_role
  task_role_arn            = var.ecs_role
  requires_compatibilities = ["FARGATE"]
  cpu                      = 1024
  memory                   = 2048
  network_mode             = "awsvpc"
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
}

resource "aws_ecs_service" "service" {
  name            = format("ecs-%s-%s-%s-service",var.team_name, var.account_environment, var.task_family_name)
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.ecs_task_def.arn
  desired_count   = var.replicas
  health_check_grace_period_seconds = "60"
  launch_type     = "FARGATE"
  network_configuration {
    security_groups  = [var.application_sg]
    subnets          = var.private_subnets
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = var.service_tg_arn
    container_name   = var.task_family_name
    container_port   = var.port
  }
}