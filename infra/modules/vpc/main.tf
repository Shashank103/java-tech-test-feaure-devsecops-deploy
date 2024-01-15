resource "aws_vpc" "main" {
  cidr_block       = "172.20.0.0/16"

  tags = {
    Name = format("%s-%s-vpc", var.team_name, var.account_environment)
  }
}

resource "aws_subnet" "public-subnet-1" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "172.20.10.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = var.availability_zones[0]
  tags = {
    Name = format("%s-%s-public-subnet-1", var.team_name, var.account_environment)
  }
}

resource "aws_subnet" "public-subnet-2" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "172.20.11.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = var.availability_zones[1]
  tags = {
    Name = format("%s-%s-public-subnet-2", var.team_name, var.account_environment)
  }
}

resource "aws_subnet" "private-subnet-1" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "172.20.20.0/24"
  map_public_ip_on_launch = "false"
  availability_zone = var.availability_zones[0]
  tags = {
    Name = format("%s-%s-private-subnet-1", var.team_name, var.account_environment)
  }
}

resource "aws_subnet" "private-subnet-2" {
  vpc_id = "${aws_vpc.main.id}"
  cidr_block = "172.20.21.0/24"
  map_public_ip_on_launch = "false"
  availability_zone = var.availability_zones[1]
  tags = {
    Name = format("%s-%s-private-subnet-2", var.team_name, var.account_environment)
    Name = format("%s-%s-private-subnet-2", var.team_name, var.account_environment)
  }
}
