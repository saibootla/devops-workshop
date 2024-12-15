provider "aws" {
  region = "us-east-1"
} 

resource "aws_instance" "ttrend-server" {
    ami = "ami-005fc0f236362e99f"
    instance_type = "t2.micro"
    key_name = "dec14"
    vpc_security_group_ids = [aws_security_group.ttrend-sg.id]
    //security_groups = [ "ttrend-sg" ]
    subnet_id = aws_subnet.ttrend-public-subnet-01.id
    for_each = toset(["Jenkins-Master", "Jenkins-Slave", "Ansible"])

    tags = {
        Name = "${each.key}"
    }
}

resource "aws_security_group" "ttrend-sg" {
  name        = "ttrend-sg"
  description = "Need for Instance Access"
  vpc_id = aws_vpc.ttrend-vpc.id

  tags = {
    Name = "ttrend-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "inbound_rules_for_jenkins" {
  security_group_id = aws_security_group.ttrend-sg.id
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "inbound_rules_for_ssh" {
  security_group_id = aws_security_group.ttrend-sg.id
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "outbound_rules" {
  security_group_id = aws_security_group.ttrend-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

#Creating VPC

resource "aws_vpc" "ttrend-vpc" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "ttrend-vpc"
  }
}

#Creating Public Subnets

resource "aws_subnet" "ttrend-public-subnet-01" {
  vpc_id     = aws_vpc.ttrend-vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1a"
  
  tags = {
    Name = "ttrend-public-subnet-01"
  }
}

resource "aws_subnet" "ttrend-public-subnet-02" {
  vpc_id     = aws_vpc.ttrend-vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1b"
  
  tags = {
    Name = "ttrend-public-subnet-02"
  }
}

#Creating Internet Gateway

resource "aws_internet_gateway" "ttrend-igw" {
  vpc_id = aws_vpc.ttrend-vpc.id

  tags = {
    Name = "ttrend-igw"
  }
}

#Creating Route Table

resource "aws_route_table" "ttrend-public-rt" {
  vpc_id = aws_vpc.ttrend-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ttrend-igw.id
  }

  tags = {
    Name = "ttrend-rt"
  }
}

#Creating Subnet Association For Route Tables

resource "aws_route_table_association" "ttrend-rta-public-subnet-01" {
  subnet_id      = aws_subnet.ttrend-public-subnet-01.id
  route_table_id = aws_route_table.ttrend-public-rt.id
}

resource "aws_route_table_association" "ttrend-rta-public-subnet-02" {
  subnet_id      = aws_subnet.ttrend-public-subnet-02.id
  route_table_id = aws_route_table.ttrend-public-rt.id
}




