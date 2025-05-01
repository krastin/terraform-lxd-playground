resource "lxd_container" "container-vault-unsealer" {
  name      = "container-vault-unsealer"
  image     = "images:debian/10/cloud/arm64"
  ephemeral = false

  config = {
    "user.user-data" = <<-EOT
        #cloud-config
        package_update: true
        package_upgrade: true
        package_reboot_if_required: true
        packages:
            - curl
            - wget
            - unzip
            - tmux
            - jq
        runcmd:
            - '\wget -q "http://releases.hashicorp.com/vault/1.6.2/vault_1.6.2_linux_arm64.zip" -O /usr/local/bin/vault.zip && unzip /usr/local/bin/vault.zip -d /usr/local/bin/'
            - '\tmux new-session -d -s "vaultSession" "vault server -dev -log-level=debug -dev-listen-address=0.0.0.0:8200 -dev-root-token-id=root &> /var/log/vault.log"'
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