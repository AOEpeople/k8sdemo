resource "aws_elb" "elb"{
  name = "${var.app_name}"
  listener {
    instance_port = "${var.port}"
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    interval = 10
    timeout = 5
    target = "TCP:${var.port}"
  }
  security_groups = ["${aws_security_group.elb.id}"]
  subnets = ["${var.elb_subnet_ids}"]
  cross_zone_load_balancing = true
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "elb" {
  name = "${var.app_name}-elb"
  vpc_id = "${var.vpc_id}"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_attachment" "elb_to_asg" {
  autoscaling_group_name = "nodes.${var.cluster_name}"
  elb = "${aws_elb.elb.id}"
}

data "aws_security_group" "kubernetes_nodes" {
  name = "nodes.${var.cluster_name}"
}

resource "aws_security_group_rule" "allow_elb" {
  security_group_id = "${data.aws_security_group.kubernetes_nodes.id}"
  type = "ingress"
  from_port = "${var.port}"
  to_port = "${var.port}"
  protocol = "tcp"
  source_security_group_id = "${aws_security_group.elb.id}"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "route" {
  zone_id = "${var.hosted_zone_id}"
  name = "${var.app_name}.${var.domain}"
  type = "A"
  alias {
    name = "${aws_elb.elb.dns_name}"
    zone_id = "${aws_elb.elb.zone_id}"
    evaluate_target_health = false
  }
}

