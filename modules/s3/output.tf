output "s3_arn" {
  value = "${aws_s3_bucket.storage.arn}"
}

output "policy_write_arn" {
  value = "${aws_iam_policy.storage_write.arn}"
}

output "policy_read_arn" {
  value = "${aws_iam_policy.storage_read.arn}"
}