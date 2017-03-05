variable "vpc_id" {
  type = "string"
}

variable "aws_azs" {
  type = "list"
}

variable "aws_region" {
  type = "string"
}

variable "key_name" {
  type = "string"
}

variable "subnet_ids" {
  type = "list"
}

variable "hosted_zone_id" {
  type = "string"
}

variable "cluster_name" {
  type = "string"
}

variable "domain_name" {
  type = "string"
}

variable "service_ports" {
  type = "map"
  default = {
    dashboard = "30000"
    demo = "30001"
  }
}
