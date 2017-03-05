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


data "aws_iam_policy_document" "access_s3" {
  statement {
    effect = "Allow"
    actions = ["s3:*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "access_s3" {
  name = "access-s3"
  path = "/"
  description = "Access S3"
  policy = "${data.aws_iam_policy_document.access_s3.json}"
}

resource "aws_iam_role_policy_attachment" "jenkins-access-s3" {
  role = "${aws_iam_role.jenkins.name}"
  policy_arn = "${aws_iam_policy.access_s3.arn}"
}
