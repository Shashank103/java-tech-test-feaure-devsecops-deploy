resource "aws_internet_gateway" "main-igw" {
  vpc_id = var.vpc_id
  tags = {
    Name = format("%s-%s-igw", var.team_name, var.account_environment)
  }
}

resource "aws_route_table" "public-subnet-rt" {
  vpc_id = var.vpc_id

  route {
    //associated subnet can reach everywhere
    cidr_block = "0.0.0.0/0"
    //Route table uses this IGW to reach internet
    gateway_id = "${aws_internet_gateway.main-igw.id}"
  }

  tags = {
    Name = format("%s-%s-igw", var.team_name, var.account_environment)
  }
}

resource "aws_route_table_association" "RT-public-subnet-1-associate"{
  subnet_id = var.public-subnet-1_id
  route_table_id = "${aws_route_table.public-subnet-rt.id}"
}

resource "aws_route_table_association" "RT-public-subnet-2-associate"{
  subnet_id = var.public-subnet-2_id
  route_table_id = "${aws_route_table.public-subnet-rt.id}"
}

# Creating an Elastic IP for the NAT Gateway!
resource "aws_eip" "Nat-Gateway-EIP" {
  vpc = true
}

# Creating a NAT Gateway!
resource "aws_nat_gateway" "NAT_GATEWAY" {
  depends_on = [
    aws_eip.Nat-Gateway-EIP
  ]
  allocation_id = aws_eip.Nat-Gateway-EIP.id
  subnet_id = var.public-subnet-1_id
  tags = {
    Name = format("%s-%s-nat-gateway", var.team_name, var.account_environment)
  }
}

# Creating a Route Table for the Nat Gateway!
resource "aws_route_table" "NAT-Gateway-RT" {
  depends_on = [
    aws_nat_gateway.NAT_GATEWAY
  ]
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.NAT_GATEWAY.id
  }
  tags = {
    Name = format("%s-%s-nat-gateway-RT", var.team_name, var.account_environment)
  }
}

resource "aws_route_table_association" "Nat-Gateway-RT-Association-1" {
  depends_on = [
    aws_route_table.NAT-Gateway-RT
  ]
  subnet_id      = var.private-subnet-1_id
  route_table_id = aws_route_table.NAT-Gateway-RT.id
}

resource "aws_route_table_association" "Nat-Gateway-RT-Association-2" {
  depends_on = [
    aws_route_table.NAT-Gateway-RT
  ]
  subnet_id      = var.private-subnet-2_id
  route_table_id = aws_route_table.NAT-Gateway-RT.id
}
