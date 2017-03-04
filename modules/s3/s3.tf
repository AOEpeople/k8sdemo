resource "aws_s3_bucket" "storage" {
  bucket = "${var.name}"
  region = "${var.region}"
  acl = "private"
}