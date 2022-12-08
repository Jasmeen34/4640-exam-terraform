terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "acitP" {
  name = "acitP"
}
data "digitalocean_project" "lab_project" {
  name = "lab 5"
}
resource "digitalocean_tag" "do_tag" {
  name = "web"
}
resource "digitalocean_vpc" "web_vpc2" {
  name   = "exam-vpc"
  region = var.region
  ip_range = var.ip_range
}

resource "digitalocean_droplet" "application_A01263293" {
  image    = var.image
  name     = "application"
  region   = var.region
  size     = "s-1vcpu-512mb-10gb"
  tags     = [digitalocean_tag.do_tag.id]
  ssh_keys = [data.digitalocean_ssh_key.acitP.id]
  vpc_uuid = digitalocean_vpc.web_vpc2.id

  lifecycle {
    create_before_destroy = true
  }
}
resource "digitalocean_droplet" "frontend_A01263293" {
  image    = var.image
  name     = "frontend"
  region   = var.region
  size     = "s-1vcpu-512mb-10gb"
  tags     = [digitalocean_tag.do_tag.id]
  ssh_keys = [data.digitalocean_ssh_key.acitP.id]
  vpc_uuid = digitalocean_vpc.web_vpc2.id

  lifecycle {
    create_before_destroy = true
  }
}
resource "digitalocean_firewall" "web" {
  name = "application"

  droplet_ids = [digitalocean_droplet.application_A01263293.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
}
  resource "digitalocean_firewall" "web2" {
  name = "only-22-80-and-443"

  droplet_ids = [digitalocean_droplet.frontend_A01263293.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["10.46.40.0/24"]
  }
  inbound_rule {
    protocol         = "icmp"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }
}
output "application" {
  value = digitalocean_droplet.application_A01263293.*.ipv4_address
}

output "frontend" {
  value = digitalocean_droplet.frontend_A01263293.*.ipv4_address
}
