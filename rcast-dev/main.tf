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

locals {
  ports_base = {
    "80"    = { proto = "tcp", desc = "HTTP (caddy)" }
    "443"   = { proto = "tcp", desc = "HTTPS (caddy)" }
    "51820" = { proto = "udp", desc = "WireGuard" }
  }

  ssh_port = var.allow_ssh ? {
    "22" = { proto = "tcp", desc = "SSH (bootstrap only)" }
  } : {}

  web_ports = merge(local.ports_base, local.ssh_port)
}

variable "allow_ssh" {
  type    = bool
}

data "cloudflare_zone" "main" {
  name = "rcast.dev"
}

resource "cloudflare_record" "wildcard_ipv4" {
  zone_id=data.cloudflare_zone.main.id
  name    = "*"
  type    = "A"
  content = hcloud_server.rcast-dev.ipv4_address
  ttl     = 1
  proxied = false
}

resource "cloudflare_record" "wildcard_ipv6" {
  zone_id=data.cloudflare_zone.main.id
  name    = "*"
  type    = "AAAA"
  content = hcloud_server.rcast-dev.ipv6_address
  ttl     = 1
  proxied = false
}

resource "cloudflare_record" "apex_ipv4" {
  zone_id=data.cloudflare_zone.main.id
  name    = "@"
  type    = "A"
  content = hcloud_server.rcast-dev.ipv4_address
  ttl     = 1
  proxied = false
}

resource "cloudflare_record" "apex_ipv6" {
  zone_id=data.cloudflare_zone.main.id
  name    = "@"
  type    = "AAAA"
  content = hcloud_server.rcast-dev.ipv6_address
  ttl     = 1
  proxied = false
}

resource "hcloud_ssh_key" "rc-ssh-key" {
  name       = "rc-ssh-key"
  public_key = file("/tmp/rc-ssh-key.pub")
}

resource "hcloud_firewall" "web-firewall" {
  name = "rcast-dev-fw"

  dynamic "rule" {
    for_each = local.web_ports

    content {
      direction   = "in"
      protocol    = rule.value.proto
      port        = rule.key
      source_ips  = ["0.0.0.0/0", "::/0"]
      description = rule.value.desc
    }
  }
}

resource "hcloud_server" "rcast-dev" {
  name        = "rcast-dev"
  server_type = "cx23"
  image       = "ubuntu-24.04"
  location    = "hel1"
  ssh_keys    = [hcloud_ssh_key.rc-ssh-key.name]
  backups = true
  firewall_ids = [hcloud_firewall.web-firewall.id]
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
  lifecycle {
    ignore_changes  = [ssh_keys]
  }
}

output "hostname" {
  description = "Server hostname"
  value       = hcloud_server.rcast-dev.name
}

output "server_ipv4" {
  description = "IPv4 address"
  value       = hcloud_server.rcast-dev.ipv4_address
}

output "server_ipv6" {
  description = "IPv6 address"
  value       = hcloud_server.rcast-dev.ipv6_address
}

# this is a semi-hacky fix, it should be possible to use
# https://github.com/nix-community/nixos-anywhere/tree/main/terraform
# unfortunately, this requires running on nixOS, and when god was distributing
# nice operating systems i was queuing for liquid glass.
resource "null_resource" "nixos" {
  depends_on = [hcloud_server.rcast-dev]

  triggers = {
    server_ip = hcloud_server.rcast-dev.ipv4_address
  }

  provisioner "local-exec" {
    command = "ROOT_HOST=${hcloud_server.rcast-dev.ipv4_address} bash ./bootstrap.sh"
  }
}
