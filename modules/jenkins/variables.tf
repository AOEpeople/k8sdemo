variable "azs" {
  type = "list"
}

variable "vpc_id" {
  type = "string"
}

variable "subnet_ids" {
  type = "list"
}

variable "ami" {
  type = "string"
}

variable "instance_type" {
  type = "string"
}

variable "key_name" {
  type = "string"
}

variable "hosted_zone_id" {
  type = "string"
}

variable "domain" {
  type = "string"
}

variable "region" {
  type = "string"
}
