module "ec2" {
  source            = "./modules/ec2"
  ami               = var.ami
  instance_type     = var.instance_type
  security_group_id = module.security_group_apache.security_group_id
  public_ipv4       = var.public_ipv4

}


module "security_group_apache" {
  source    = "./modules/security_groups"
  name      = var.name
  cidr_ipv4 = var.cidr_ipv4

}