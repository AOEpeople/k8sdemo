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
  roles = ["${aws_iam_role.jenkins.name}"]
}
