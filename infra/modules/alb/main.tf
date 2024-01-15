resource "aws_alb" "main-ext-lb" {
  name = format("%s-%s-load-balancer", var.team_name, var.account_environment)
  internal = false
  load_balancer_type = "application"
  subnets = ["${var.public-subnet-1_id}","${var.public-subnet-2_id}"]
  security_groups = ["${var.alb_security_group}"]
  tags = {
    Name = format("%s-%s-load-balancer",var.team_name, var.account_environment)
  }
}

resource "aws_alb_target_group" "port80-tg-1" {
  name     = format("%s-%s-port80-tg-1",var.team_name, var.account_environment)
  port     = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = var.vpc_id

  health_check {
    path = "/"
    matcher = "200"
  }
  tags = {
    Name = format("%s-%s-port80-tg-1",var.team_name, var.account_environment)
  }
}

resource "aws_alb_target_group" "port8080-tg-2" {
  name     = format("%s-%s-port8080-tg-2",var.team_name, var.account_environment)
  port     = 8080
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = var.vpc_id

  health_check {
    path = "/"
    matcher = "200"
  }
  tags = {
    Name = format("%s-%s-port8080-tg-2",var.team_name, var.account_environment)
  }
}

resource "aws_alb_listener" "alb-listener-80" {
  load_balancer_arn = aws_alb.main-ext-lb.arn
  port = "80"
  protocol = "HTTP"
  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.port8080-tg-2.arn
  }
}