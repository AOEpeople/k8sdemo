variable "vpc_id" {
  type = "string"
}

variable "subnet_ids" {
  type = "list"
}

variable "key_name" {
  type = "string"
}

variable "aws_region" {
  type = "string"
}

variable "aws_azs" {
  type = "list"
}

variable "ubuntu_1604_amis" {
  type = "map"
  default = {
    eu-central-1 = "ami-5aee2235"
  }
}

variable "hosted_zone_id" {
  type = "string"
}
