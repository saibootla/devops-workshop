provider "aws" {
  region = "us-east-1"
}

// Creating EC2 instance 

resource "aws_instance" "server" {
  ami           = "ami-0a0e5d9c7acc336f1"
  instance_type = "t2.micro"
  key_name      = "sep12"
  // security_groups = [ "demo-sg" ]
  vpc_security_group_ids = [aws_security_group.demo-sg.id]
  subnet_id              = aws_subnet.ttrend-subnet-01.id
}

// Creating Security Group

resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "SSH Access"
  vpc_id      = aws_vpc.ttrend-vpc.id


  tags = {
    Name = "demo-sg"
  }
}

// Creating inbound and outbound rules

resource "aws_vpc_security_group_ingress_rule" "allow_tls_ipv4" {
  security_group_id = aws_security_group.demo-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.demo-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

// Creating VPC

resource "aws_vpc" "ttrend-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "ttrend-vpc"
  }
}

// Creating Subnets 

resource "aws_subnet" "ttrend-subnet-01" {
  vpc_id                  = aws_vpc.ttrend-vpc.id
  cidr_block              = "10.1.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1a"
  tags = {
    Name = "ttrend-subnet-01"
  }
}

resource "aws_subnet" "ttrend-subnet-02" {
  vpc_id                  = aws_vpc.ttrend-vpc.id
  cidr_block              = "10.1.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1b"
  tags = {
    Name = "ttrend-subnet-02"
  }
}

// Creating Internet Gateway

resource "aws_internet_gateway" "ttrend-igw" {
  vpc_id = aws_vpc.ttrend-vpc.id
  tags = {
    Name = "ttrend-igw"
  }
}

// Creating Route Table

resource "aws_route_table" "ttrend-rt" {
  vpc_id = aws_vpc.ttrend-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ttrend-igw.id
  }
}

// Creating Route Table Association for the Subnets

resource "aws_route_table_association" "ttrend-rta-01" {
  subnet_id      = aws_subnet.ttrend-subnet-01.id
  route_table_id = aws_route_table.ttrend-rt.id
}

resource "aws_route_table_association" "ttrend-rta-02" {
  subnet_id      = aws_subnet.ttrend-subnet-02.id
  route_table_id = aws_route_table.ttrend-rt.id
}