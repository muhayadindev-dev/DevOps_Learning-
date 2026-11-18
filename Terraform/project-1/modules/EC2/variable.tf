variable "ami" {
  type  = string
  description = " ami id for the wordpress EC2 instance"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
}

variable "security_group_id" {
    type = string 
}