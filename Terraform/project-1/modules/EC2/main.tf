resource "aws_instance" "terra_1" {
  ami    = var.ami
  instance_type = var.instance_type
  associate_public_ip_address = true
 vpc_security_group_ids = [var.security_group_id]
 user_data = file("${path.module}/install-wordpress.sh")
  tags = {
    Name = "project_1"
  }
}


