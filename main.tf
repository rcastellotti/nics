terraform {
  required_version = ">= 1.5.0"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.48.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
  backend "s3" {
    bucket                      = "terraform"
    key                         = "terraform.tfstate"
    workspace_key_prefix        = ""
    region                      = "auto"
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    use_path_style              = true
    endpoints = {
      s3 = "https://63540284f50c1886beda4daca5793813.r2.cloudflarestorage.com"
    }
  }
}


data "cloudflare_zone" "domain" {
  name = "rcastellotti.dev"
}

resource "cloudflare_record" "wildcard_ipv6" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "*"
  type    = "AAAA"
  content = hcloud_server.rcastellotti-dev.ipv6_address
  ttl     = 1
  proxied = false
}

resource "cloudflare_record" "wildcard_ipv4" {
  zone_id = data.cloudflare_zone.domain.id
  name    = "*"
  type    = "A"
  content = hcloud_server.rcastellotti-dev.ipv4_address
  ttl     = 1
  proxied = false
}

locals {
  web_tcp_ports = {
    "80"  = "HTTP (caddy)"
    "443" = "HTTPS (caddy)"
    "22" = "SSH (bootstrap only)"
  }
}

resource "hcloud_ssh_key" "rc-ssh-key" {
  name       = "my-ssh-key"
  public_key = file("/tmp/rc-ssh-key.pub")
}

resource "hcloud_firewall" "web-firewall" {
  name = "rcastellotti-dev-web-firewall"

  dynamic "rule" {
    for_each = local.web_tcp_ports
    content {
      direction   = "in"
      protocol    = "tcp"
      port        = rule.key
      source_ips  = ["0.0.0.0/0", "::/0"]
      description = rule.value
    }
  }
}

resource "hcloud_server" "rcastellotti-dev" {
  name        = "rcastellotti-dev"
  server_type = "cx23"
  image       = "ubuntu-24.04"
  location    = "hel1"
  ssh_keys = [hcloud_ssh_key.rc-ssh-key.name]
  public_net {
    ipv4_enabled = true # unlucky
    ipv6_enabled = true
  }
}

resource "hcloud_firewall_attachment" "web_fw_attach" {
  firewall_id = hcloud_firewall.web-firewall.id
  server_ids  = [hcloud_server.rcastellotti-dev.id]
}

output "hostname" {
  description = "Server hostname"
  value       = hcloud_server.rcastellotti-dev.name
}

output "server_ipv4" {
  description = "IPv4 address"
  value       = hcloud_server.rcastellotti-dev.ipv4_address
}

output "server_ipv6" {
  description = "IPv6 address"
  value       = hcloud_server.rcastellotti-dev.ipv6_address
}
