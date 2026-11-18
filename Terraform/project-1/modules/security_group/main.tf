
resource "aws_security_group" "WordPress_sg" {
  name        = var.name
  description = var.description

  tags = {
    Name = "wordpress-web"
  }
}

resource "aws_vpc_security_group_ingress_rule" "inbound_http" {
  security_group_id = aws_security_group.WordPress_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "outbound_http" {
  security_group_id = aws_security_group.WordPress_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" 
}


resource "aws_vpc_security_group_ingress_rule" "ssh_connection" {
  security_group_id = aws_security_group.WordPress_sg.id
  cidr_ipv4         = "3.8.37.24/29"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}
