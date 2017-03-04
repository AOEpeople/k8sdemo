data "aws_iam_policy_document" "storage_read" {
  statement {
    effect = "Allow"
    actions = [
      "s3:List*",
      "s3:Get*",
    ]
    resources = [
      "${aws_s3_bucket.storage.arn}/*",
      "${aws_s3_bucket.storage.arn}",
    ]
  }
}

data "aws_iam_policy_document" "storage_write" {
  statement {
    effect = "Allow"
    actions = [
      "s3:Put*",
      "s3:Get*",
      "s3:DeleteObject*",
      "s3:AbortMultipartUpload",
      "s3:List*",
      "s3:*"
    ]
    resources = [
      "${aws_s3_bucket.storage.arn}/*",
      "${aws_s3_bucket.storage.arn}",
    ]
  }
}

resource "aws_iam_policy" "storage_write" {
  name = "${var.name}-read"
  path = "/"
  description = "read access to central storage"
  policy = "${data.aws_iam_policy_document.storage_read.json}"
}

resource "aws_iam_policy" "storage_read" {
  name = "${var.name}-write"
  path = "/"
  description = "write access to central storage"
  policy = "${data.aws_iam_policy_document.storage_write.json}"
}
