resource "aws_elb" "jenkins" {
  name = "jenkins"
  listener {
    instance_port = 8080
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 10
    timeout = 3
    target = "TCP:8080"
    interval = 5
  }
  security_groups = ["${aws_security_group.elb.id}"]
  subnets = ["${var.subnet_ids}"]
}

resource "aws_autoscaling_group" "jenkins" {
  availability_zones = "${var.azs}"
  name = "jenkins"
  max_size = "1"
  min_size = "1"
  desired_capacity = "1"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.jenkins.name}"
  load_balancers = ["${aws_elb.jenkins.name}"]
  tag {
    key = "Name"
    value = "Jenkins"
    propagate_at_launch = "true"
  }
  tag {
    key = "inspector"
    value = "User:ubuntu"
    propagate_at_launch = false
  }
  lifecycle {
    create_before_destroy = true
  }
  vpc_zone_identifier = ["${var.subnet_ids}"]
}

resource "aws_launch_configuration" "jenkins" {
  name_prefix = "jenkins-"
  image_id = "${var.ami}"
  instance_type = "${var.instance_type}"
  iam_instance_profile = "${aws_iam_instance_profile.jenkins.name}"
  security_groups = [
    "${aws_security_group.jenkins.id}"
  ]
  user_data = "${file("${path.module}/userdata.sh")}"
  key_name = "${var.key_name}"
  lifecycle {
    create_before_destroy = true
  }

  root_block_device {
    volume_size = "80"
    volume_type = "standard"
    delete_on_termination = "true"
  }
}

resource "aws_security_group" "jenkins" {
  name = "jenkins-asg"
  vpc_id = "${var.vpc_id}"
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    security_groups = ["${aws_security_group.elb.id}"]
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "elb" {
  name = "jenkins-elb"
  vpc_id = "${var.vpc_id}"
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
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
}

resource "aws_route53_record" "jenkins" {
  zone_id = "${var.hosted_zone_id}"
  name = "${var.domain}"
  type = "A"
  alias {
    name = "${aws_elb.jenkins.dns_name}"
    zone_id = "${aws_elb.jenkins.zone_id}"
    evaluate_target_health = true
  }
}
