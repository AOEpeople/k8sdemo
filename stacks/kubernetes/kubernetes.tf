resource "null_resource" "launch_kube" {

  triggers {
    # this resource will only be executed if version changes
    version = "${md5(file("${path.module}/launch_kube.sh"))}"
  }

  provisioner "local-exec" {
    command = "${join(" ",list(
      "bash +x",
      "${path.module}/launch_kube.sh",
      "-v '${var.vpc_id}'",
      "-c '${var.cluster_name}'",
      "-k 's3://muckops/'",
      "-z '${join(",", var.aws_azs)}'",
      "-m '${element(var.aws_azs, 0)}'",
      "-n '${var.key_name}'"
    ))}"
  }
}
