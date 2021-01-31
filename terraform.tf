terraform {
  required_providers {
    lxd = {
      source  = "terraform-lxd/lxd"
      version = "1.5.0"
    }
  }
}

provider "lxd" {
  generate_client_certificates = true
  accept_remote_certificate    = true

  lxd_remote {
    name = "raspberrypi8"
  }
}

resource "lxd_network" "net-consul" {
  name = "net-consul"

  config = {
    "ipv4.address" = "10.100.101.1/24"
    "ipv4.nat"     = "true"
    "ipv6.address" = "auto"
    "ipv6.nat"     = "true"
  }
}

resource "lxd_profile" "profile-consul" {
  name = "profile-consul"

  config = {
    "user.user-data" = <<EOT
#cloud-config
package_update: true
package_upgrade: true
package_reboot_if_required: true
packages:
    - curl
    - wget
    - unzip
runcmd:
    - '\env VERSION="1.8.1" bash -c "$(curl -fsSL https://raw.githubusercontent.com/krastin/hashistack-provisioning/lxd/lxd/consul/install/install_consul.sh)"'
EOT
  }

  device {
    name = "eth0"
    type = "nic"

    properties = {
      nictype = "bridged"
      parent  = lxd_network.net-consul.name
    }
  }

  device {
    type = "disk"
    name = "root"

    properties = {
      pool = "default"
      path = "/"
    }
  }
}

resource "lxd_container" "container-consul" {
  count     = 1
  name      = "container-consul-${count.index}"
  image     = "images:debian/10/cloud/arm64"
  ephemeral = false
  profiles  = [lxd_profile.profile-consul.name]
}

output "ips" {
  value = [lxd_container.container-consul.*.ipv4_address]
}