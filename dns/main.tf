terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.68"
    }
  }
}

variable "hcloud_token" {
  description = "Hetzner Cloud API Token"
  type        = string
  sensitive   = true
}

provider "hcloud" {
  token = var.hcloud_token
}

resource "hcloud_network" "internal_net" {
  name     = "internal-net"
  ip_range = "10.0.0.0/16"
}

resource "hcloud_network_subnet" "internal_subnet" {
  type         = "cloud"
  network_id   = hcloud_network.internal_net.id
  network_zone = "eu-central"
  ip_range     = "10.0.0.0/24"
}

resource "hcloud_ssh_key" "default" {
  name       = "demo-key"
  public_key = file("~/.ssh/dns.pub")
}

resource "hcloud_server" "dns_server" {
  name        = "dns-server"
  image       = "ubuntu-24.04"
  server_type = "cx23"
  location    = "nbg1"
  ssh_keys    = [hcloud_ssh_key.default.id]

  network {
    network_id = hcloud_network.internal_net.id
    ip         = "10.0.0.2"
  }
  depends_on = [hcloud_network_subnet.internal_subnet]

  user_data = <<-EOF
    #cloud-config
    package_update: true
    packages:
      - bind9
      - bind9utils
      - dnsutils
    write_files:
      - path: /etc/bind/named.conf.options
        encoding: b64
        content: ${base64encode(file("${path.module}/configs/DNS_named.conf.options"))}
      - path: /etc/bind/named.conf.local
        encoding: b64
        content: ${base64encode(file("${path.module}/configs/DNS_named.conf.local"))}
      - path: /etc/bind/db.demo.internal
        encoding: b64
        content: ${base64encode(file("${path.module}/configs/DNS_db.demo.internal"))}
    runcmd:
      - systemctl restart bind9
    power_state:
      mode: reboot
      message: "Rebooting to initialize Hetzner private network interface"
  EOF
}

resource "hcloud_server" "client_1" {
  name        = "client-1"
  image       = "ubuntu-24.04"
  server_type = "cx23"
  location    = "nbg1"
  ssh_keys    = [hcloud_ssh_key.default.id]

  network {
    network_id = hcloud_network.internal_net.id
    ip         = "10.0.0.3"
  }
  depends_on = [hcloud_network_subnet.internal_subnet]

  user_data = <<-EOF
    #cloud-config
    write_files:
      - path: /etc/systemd/resolved.conf
        encoding: b64
        content: ${base64encode(file("${path.module}/configs/CLIENT_resolved.conf"))}
    runcmd:
      - systemctl restart systemd-resolved
    power_state:
      mode: reboot
      message: "Rebooting to initialize Hetzner private network interface"
  EOF
}

resource "hcloud_server" "client_2" {
  name        = "client-2"
  image       = "ubuntu-24.04"
  server_type = "cx23"
  location    = "nbg1"
  ssh_keys    = [hcloud_ssh_key.default.id]

  network {
    network_id = hcloud_network.internal_net.id
    ip         = "10.0.0.4"
  }
  depends_on = [hcloud_network_subnet.internal_subnet]

  user_data = <<-EOF
    #cloud-config
    write_files:
      - path: /etc/systemd/resolved.conf
        encoding: b64
        content: ${base64encode(file("${path.module}/configs/CLIENT_resolved.conf"))}
    runcmd:
      - systemctl restart systemd-resolved
    power_state:
      mode: reboot
      message: "Rebooting to initialize Hetzner private network interface"
  EOF
}

output "dns_server_public_ip" { value = hcloud_server.dns_server.ipv4_address }
output "client_1_public_ip" { value = hcloud_server.client_1.ipv4_address }
output "client_2_public_ip" { value = hcloud_server.client_2.ipv4_address }
