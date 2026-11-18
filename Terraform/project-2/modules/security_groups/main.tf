

resource "aws_security_group" "apache_sg" {
  name        = var.name
  description = "Allow HTTP inbound traffic and all outbound traffic"

  tags = {
    Name = "application.sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "inbound_http" {
  security_group_id = aws_security_group.apache_sg.id
  cidr_ipv4         = var.cidr_ipv4
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "outbound_" {
  security_group_id = aws_security_group.apache_sg.id
  cidr_ipv4         = var.cidr_ipv4
  ip_protocol       = "-1"

}


