variable "ami" {
  type        = string
  description = " ami id for the wordpress EC2 instance"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}


variable "name" {
  description = "name of the WordPress security group"
  type        = string
}

variable "description" {
  description = "description of the WordPress security group"
  type        = string
}

