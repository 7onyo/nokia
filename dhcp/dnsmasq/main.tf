terraform {
  required_version = ">= 1.0"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.7.1"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

variable "pool_name" {
  description = "Libvirt storage pool name"
  type        = string
  default     = "default"
}

resource "libvirt_network" "dhcp_test_net" {
  name      = "dhcp-test-net"
  mode      = "none" 
  bridge    = "virbr-dhcp"
  dhcp {
    enabled = false
  }
}

resource "libvirt_volume" "ubuntu_image" {
  name   = "ubuntu-base-image.qcow2"
  pool   = var.pool_name
  source = "https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img"
  format = "qcow2"
}

resource "libvirt_volume" "server_disk" {
  name           = "dhcp-server-disk.qcow2"
  base_volume_id = libvirt_volume.ubuntu_image.id
  pool           = var.pool_name
  size           = 10737418240
}

resource "libvirt_volume" "client_disk" {
  name           = "dhcp-client-disk.qcow2"
  base_volume_id = libvirt_volume.ubuntu_image.id
  pool           = var.pool_name
  size           = 10737418240
}

resource "libvirt_cloudinit_disk" "server_cloudinit" {
  name           = "dhcp-server-cloudinit.iso"
  pool           = var.pool_name
  user_data      = file("${path.module}/configs/server-cloud-init.yaml")
  network_config = file("${path.module}/configs/server-network.yaml")
}

resource "libvirt_cloudinit_disk" "client_cloudinit" {
  name           = "dhcp-client-cloudinit.iso"
  pool           = var.pool_name
  user_data      = file("${path.module}/configs/client-cloud-init.yaml")
  network_config = file("${path.module}/configs/client-network.yaml")
}

resource "libvirt_domain" "dhcp_server" {
  name   = "dhcp-server"
  memory = "2048"
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.server_cloudinit.id

  network_interface {
    network_name   = "default"
    wait_for_lease = true
  }

  network_interface {
    network_id = libvirt_network.dhcp_test_net.id
  }

  disk {
    volume_id = libvirt_volume.server_disk.id
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
  console {
    type        = "pty"
    target_port = "1"
    target_type = "virtio"
  }
  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

resource "libvirt_domain" "dhcp_client" {
  name   = "dhcp-client"
  memory = "2048"
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.client_cloudinit.id

  network_interface {
    network_name   = "default"
    wait_for_lease = true
  }

  network_interface {
    network_id = libvirt_network.dhcp_test_net.id
  }


  disk {
    volume_id = libvirt_volume.client_disk.id
  }

  console {
    type        = "pty"
    target_port = "0"
    target_type = "serial"
  }
  console {
    type        = "pty"
    target_port = "1"
    target_type = "virtio"
  }
  graphics {
    type        = "spice"
    listen_type = "address"
    autoport    = true
  }
}

output "server_management_ip" {
  description = "The SSH IP for the DHCP Server"
  value       = length(libvirt_domain.dhcp_server.network_interface[0].addresses) > 0 ? libvirt_domain.dhcp_server.network_interface[0].addresses[0] : "No IP"
}

output "client_management_ip" {
  description = "The SSH IP for the DHCP Client"
  value       = length(libvirt_domain.dhcp_client.network_interface[0].addresses) > 0 ? libvirt_domain.dhcp_client.network_interface[0].addresses[0] : "No IP"
}
