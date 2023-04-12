variable "ami_id" {
  description = "This is the ami id for ubuntu 20.0 image"
  type = string
}

variable "instance_size" {
  description = "This is the instance size of the ec2 instance"
  type = string
}

variable "cidr_block" {
  description = "Cidr block used to create vpc"
  type = string
}