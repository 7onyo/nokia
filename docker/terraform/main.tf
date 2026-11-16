terraform {
  required_providers {
    hcloud = { source = "hetznercloud/hcloud", version = "~> 1.70.2" }
  }
}

variable "hcloud_token" { sensitive = true }
provider "hcloud" { token = var.hcloud_token }

resource "hcloud_ssh_key" "default" {
  name       = "docker-ssh-key"
  public_key = file("../.secrets/docker_demo.pub")
}

resource "hcloud_server" "docker_node" {
  name        = "dockerDemoVM"
  image       = "rocky-10"
  server_type = "cpx22"
  ssh_keys    = [hcloud_ssh_key.default.id]
  labels      = { role = "docker" }
}

output "server_ip" { value = hcloud_server.docker_node.ipv4_address }