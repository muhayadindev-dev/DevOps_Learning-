resource "aws_instance" "apache_1" {
  ami                    = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.security_group_id]
  user_data = templatefile("${path.module}/cloud_init.yml", {
    html_content = filebase64("${path.module}/index.html")
  })
  associate_public_ip_address = var.public_ipv4

  tags = {
    Name = "Terra.done"
  }
}
