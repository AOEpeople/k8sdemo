variable "port" {
  type = "string"
}

variable "vpc_id" {
  type = "string"
}

variable "hosted_zone_id" {
  type = "string"
}

variable "elb_subnet_ids" {
  type = "list"
}

variable "app_name" {
  type = "string"
}

variable "domain" {
  type = "string"
}

variable "cluster_name" {
  type = "string"
}
