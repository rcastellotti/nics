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
  domains = {
    primary   = "rcastellotti.dev"
    secondary = "rcast.dev"
  }

  server_ipv4 = hcloud_server.rcast-dev.ipv4_address
  server_ipv6 = hcloud_server.rcast-dev.ipv6_address
}

data "cloudflare_zone" "zones" {
  for_each = local.domains

  name = each.value
}

resource "cloudflare_record" "wildcard_ipv6" {
  for_each = local.domains

  zone_id = data.cloudflare_zone.zones[each.key].id
  name    = "*"
  type    = "AAAA"
  content = local.server_ipv6
  ttl     = 1
  proxied = false
}

resource "cloudflare_record" "wildcard_ipv4" {
  for_each = local.domains

  zone_id = data.cloudflare_zone.zones[each.key].id
  name    = "*"
  type    = "A"
  content = local.server_ipv4
  ttl     = 1
  proxied = false
}
resource "cloudflare_record" "apex_ipv4" {
  for_each = local.domains

  zone_id = data.cloudflare_zone.zones[each.key].id
  name    = "@"
  type    = "A"
  content = local.server_ipv4
  ttl     = 1
  proxied = false
}

resource "cloudflare_record" "apex_ipv6" {
  for_each = local.domains

  zone_id = data.cloudflare_zone.zones[each.key].id
  name    = "@"
  type    = "AAAA"
  content = local.server_ipv6
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
  name       = "rc-ssh-key"
  public_key = file("/tmp/rc-ssh-key.pub")
}

resource "hcloud_firewall" "web-firewall" {
  name = "rcast-dev-web-firewall"

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

resource "hcloud_server" "rcast-dev" {
  name        = "rcast-dev"
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
  server_ids  = [hcloud_server.rcast-dev.id]
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
