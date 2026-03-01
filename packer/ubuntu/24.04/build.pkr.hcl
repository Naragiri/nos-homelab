build {
  name    = "ubuntu-2404"
  sources = ["source.proxmox-iso.ubuntu-2404"]

  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "doas rm /etc/ssh/ssh_host_*",
      "doas truncate -s 0 /etc/machine-id",
      "doas apt -y autoremove --purge",
      "doas apt -y clean",
      "doas apt -y autoclean",
      "doas cloud-init clean",
      "doas rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
      "doas rm -f /etc/netplan/00-installer-config.yaml",
      "doas sync"
    ]
  }

  provisioner "file" {
    source      = "${path.root}/files/99-pve.cfg"
    destination = "/tmp/99-pve.cfg"
  }

  provisioner "shell" {
    inline = [ "doas cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]
  }

  provisioner "shell" {
    inline = ["echo 'permit persist :sudo' | doas tee /etc/doas.conf"]
  }
}