module "jenkins" {
  source = "../../modules/jenkins/"
  vpc_id = "${var.vpc_id}"
  ami = "${lookup(var.ubuntu_1604_amis, var.aws_region)}"
  domain = "jenkins.aoeplay.net"
  azs = "${var.aws_azs}"
  hosted_zone_id = "${var.hosted_zone_id}"
  instance_type = "c4.large"
  key_name = "${var.key_name}"
  region = "${var.aws_region}"
  subnet_ids = [ "${var.subnet_ids}" ]
}
