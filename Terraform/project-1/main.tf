module "ec2" {
  source            = "./modules/EC2"
  ami               = var.ami
  instance_type     = var.instance_type
  security_group_id = module.security_group.security_group_id
}

module "security_group" {
  source      = "./modules/security_group"
  name        = var.name
  description = var.description
}
