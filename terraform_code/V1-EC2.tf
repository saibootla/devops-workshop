provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "server" {
    ami = "ami-0a5c3558529277641"
    instance_type = "t2.micro"
    key_name = "sep12"
    security_groups = [ "demo-sg" ]
}

resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "SSH Access"
  

  tags = {
    Name = "demo-sg"
  }
}

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
