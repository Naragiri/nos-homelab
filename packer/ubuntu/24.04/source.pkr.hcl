locals {
  hashed_ssh_password = bcrypt(var.ssh_password)
}

source "proxmox-iso" "ubuntu-2404" {
  proxmox_url = var.proxmox_url
  username = var.proxmox_token_id
  token = var.proxmox_token_secret
  node = var.proxmox_node
  insecure_skip_tls_verify = true

  vm_id = var.vm_id
  vm_name = var.vm_name
  cores = var.vm_cores
  memory = var.vm_memory

  bios = "seabios"
  machine = "q35"
  cpu_type = "host"
  os = "l26"

  boot_iso {
    type = "ide"
    iso_file = "${var.iso_storage_pool}:iso/${var.iso_name}"
    unmount = true
  }

  disks {
    disk_size = var.vm_disk_size
    storage_pool = var.vm_storage_pool
    type = "scsi"
    format = "raw"
    ssd = true
    discard = true
  }

  network_adapters {
    model = "virtio"
    bridge = "vmbr0"
    vlan_tag = "10"
  }

  cloud_init = true
  cloud_init_storage_pool = var.vm_storage_pool

  # Packer spins up a local HTTP server serving the http/ directory
  # Ubuntu's installer fetches user-data from it during boot
  http_port_min = 8802
  http_port_max = 8802
  http_content = {
    "/user-data" = templatefile("http/user-data", {
      ssh_username = var.ssh_username
      ssh_public_key = var.ssh_public_key
      hashed_ssh_password = local.hashed_ssh_password
    })
    "/meta-data" = ""
  }

  # Tells the Ubuntu installer where to find the autoinstall config
  boot_wait = "10s"
  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    "<bs><bs><bs><bs><wait>",
    "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
    "<f10><wait>"
  ]

  # Packer uses this to connect after install completes
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  ssh_timeout = "30m"
  ssh_handshake_attempts = 30
  ssh_pty = true

  template_name = var.vm_name
  template_description = "Ubuntu 24.04 Base Image"
  qemu_agent = true
}