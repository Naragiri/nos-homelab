variable "proxmox_url" {
  type = string
}

variable "proxmox_node" {
  type = string
}

variable "proxmox_token_id" {
  type = string
  sensitive = true
}

variable "proxmox_token_secret" {
  type = string
  sensitive = true
}

variable "vm_id" {
  type = number
  default = 9000
}

variable "vm_name" {
  type = string
  description = "Name of the template"
  default = "ubuntu-24.04-base"
}

variable "vm_cores" {
  type = number
  default = 2
}

variable "vm_memory" {
  type = number
  default = 2048
}

variable "vm_disk_size" {
  type = string
  default = "20G"
}

variable "vm_storage_pool" {
  type = string
}

variable "iso_name" {
  type = string
  default = "ubuntu-24.04.4-live-server-amd64.iso"
}

variable "iso_storage_pool" {
  type = string
  default = "local"
}

variable "ssh_username" {
  type = string
  default = "nara"
}

variable "ssh_password" {
  type = string
  sensitive = true
}

variable "ssh_public_key" {
  type = string
}