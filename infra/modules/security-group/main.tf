resource "aws_security_group" "main-ext-alb-sg" {
  vpc_id = var.vpc_id
  name = format("%s-%s-ext-alb-sg",var.team_name, var.account_environment)
  description = "Application load balancer instance access"
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = format("%s-%s-ext-alb-sg",var.team_name, var.account_environment)
  }
}

resource "aws_security_group" "main-int-service-sg" {
  vpc_id = var.vpc_id
  name = format("%s-%s-int-service-sg",var.team_name, var.account_environment)
  description = "Application load balancer instance access"
  tags = {
    Name = format("%s-%s-int-service-sg",var.team_name, var.account_environment)
  }
}


resource "aws_security_group_rule" "main-int-service-sg-ingress" {
  type = "ingress"
  from_port = 0
  to_port = 65535
  protocol = "tcp"
  security_group_id = aws_security_group.main-int-service-sg.id
  source_security_group_id = aws_security_group.main-ext-alb-sg.id
  description = "Accept traffic from ALB"
}

resource "aws_security_group_rule" "main-int-service-sg-egress" {
  type = "egress"
  from_port = 0
  to_port = 0
  protocol = "-1"
  cidr_blocks = [
    "0.0.0.0/0"
  ]
  security_group_id = aws_security_group.main-int-service-sg.id
}