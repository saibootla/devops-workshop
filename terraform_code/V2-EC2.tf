provider "aws" {
  region = "us-east-1"
} 

resource "aws_instance" "demo-server" {
    ami = "ami-0166fe664262f664c"
    instance_type = "t2.micro"
    key_name = "dec14"
    security_groups = [ "demo-sg" ]
}

resource "aws_security_group" "demo-sg" {
  name        = "demo-sg"
  description = "SSH Access"

  tags = {
    Name = "SSH-SG"
  }
}

resource "aws_vpc_security_group_ingress_rule" "inbound_rules_for_jenkins" {
  security_group_id = aws_security_group.demo-sg.id
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_ingress_rule" "inbound_rules_for_ssh" {
  security_group_id = aws_security_group.demo-sg.id
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
  cidr_ipv4         = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "outbound_rules" {
  security_group_id = aws_security_group.demo-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
