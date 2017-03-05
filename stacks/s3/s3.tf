module "kops_state_bucket" {
  source = "../../modules/s3"
  name = "muckops"
  region = "${var.aws_region}"
}
