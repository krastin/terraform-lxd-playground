resource "null_resource" "consul-provisioner" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    cluster_instance_ips = join(",", lxd_container.container-consul.*.ipv4_address)
  }

  provisioner "local-exec" {
    command = "echo ${join(",", lxd_container.container-consul.*.ipv4_address)}"
  }
}
