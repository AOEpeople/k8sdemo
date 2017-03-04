resource "aws_iam_role_policy_attachment" "jenkins-policy" {
  role = "${aws_iam_role.jenkins.name}"
  count = "${length(var.iam_policy_arns)}"
  policy_arn = "${element(var.iam_policy_arns, count.index)}"
}

resource "aws_iam_role" "jenkins" {
  name = "jenkins"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "jenkins" {
  name = "jenkins"
  roles = [
    "${aws_iam_role.jenkins.name}"
  ]
}
