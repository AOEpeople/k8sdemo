module "kubernetes-dashboard" {
  source = "../../modules/kubernetes_service/"
  app_name = "dashboard"
  port = "${lookup(var.service_ports, "dashboard")}"
  elb_subnet_ids = ["${var.subnet_ids}"]
  hosted_zone_id = "${var.hosted_zone_id}"
  vpc_id = "${var.vpc_id}"
  domain = "${var.domain_name}"
  cluster_name = "${var.cluster_name}"
}
