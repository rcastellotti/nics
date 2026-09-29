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
  ports = {
    "22"  = { proto = "tcp", desc = "SSH" }
    "80"  = { proto = "tcp", desc = "HTTP (caddy)" }
    "443" = { proto = "tcp", desc = "HTTPS (caddy)" }
  }
}

data "cloudflare_zone" "main" {
  name = "rcastellotti.dev"
}

resource "cloudflare_record" "local" {
  zone_id = data.cloudflare_zone.main.id
  name    = "local"
  type    = "A"
  content = "192.168.1.201"
  ttl     = 1
  proxied = false
}

resource "cloudflare_record" "discord" {
  zone_id = data.cloudflare_zone.main.id
  name    = "d"
  type    = "A"
  content = "192.0.2.1"
  ttl     = 1
  proxied = true
}

resource "cloudflare_ruleset" "discord_redirect" {
  zone_id = data.cloudflare_zone.main.id
  name    = "Discord redirect"
  kind    = "zone"
  phase   = "http_request_dynamic_redirect"
  rules {
    ref         = "discord_redirect"
    description = "Redirect Discord subdomain to Discord invite"
    expression  = "(http.host eq \"d.rcastellotti.dev\")"
    action      = "redirect"
    action_parameters {
      from_value {
        status_code = 301
        target_url {
          value = "https://discord.gg/vnUQQwyVE5"
        }
        preserve_query_string = false
      }
    }
  }
}

resource "cloudflare_record" "wildcard_ipv4" {
  zone_id = data.cloudflare_zone.main.id
  name    = "*"
  type    = "A"
  content = hcloud_server.kodiak.ipv4_address
  ttl     = 1
  proxied = false
}

resource "cloudflare_record" "wildcard_ipv6" {
  zone_id = data.cloudflare_zone.main.id
  name    = "*"
  type    = "AAAA"
  content = hcloud_server.kodiak.ipv6_address
  ttl     = 1
  proxied = false
}

resource "cloudflare_record" "apex_ipv4" {
  zone_id = data.cloudflare_zone.main.id
  name    = "@"
  type    = "A"
  content = hcloud_server.kodiak.ipv4_address
  ttl     = 1
  proxied = false
}

resource "cloudflare_record" "apex_ipv6" {
  zone_id = data.cloudflare_zone.main.id
  name    = "@"
  type    = "AAAA"
  content = hcloud_server.kodiak.ipv6_address
  ttl     = 1
  proxied = false
}

resource "hcloud_ssh_key" "rc-ssh-key" {
  name       = "rc-ssh-key"
  public_key = file("/tmp/grizzly-ssh-key.pub")
}

resource "hcloud_firewall" "web-firewall" {
  name = "kodiak-fw"

  dynamic "rule" {
    for_each = local.ports

    content {
      direction   = "in"
      protocol    = rule.value.proto
      port        = rule.key
      source_ips  = ["0.0.0.0/0", "::/0"]
      description = rule.value.desc
    }
  }
}

resource "hcloud_server" "kodiak" {
  name         = "kodiak"
  server_type  = "cx23"
  image        = "ubuntu-24.04"
  location     = "hel1"
  ssh_keys     = [hcloud_ssh_key.rc-ssh-key.name]
  backups      = true
  firewall_ids = [hcloud_firewall.web-firewall.id]
  public_net {
    ipv4_enabled = true
    ipv6_enabled = true
  }
  lifecycle {
    ignore_changes = [ssh_keys]
  }
}

moved {
  from = hcloud_server.rcastellotti-dev
  to   = hcloud_server.kodiak
}

output "hostname" {
  description = "Server hostname"
  value       = hcloud_server.kodiak.name
}

output "server_ipv4" {
  description = "IPv4 address"
  value       = hcloud_server.kodiak.ipv4_address
}

output "server_ipv6" {
  description = "IPv6 address"
  value       = hcloud_server.kodiak.ipv6_address
}

module "deploy" {
  source                 = "github.com/nix-community/nixos-anywhere//terraform/all-in-one"
  nixos_system_attr      = ".#nixosConfigurations.kodiak.config.system.build.toplevel"
  nixos_partitioner_attr = ".#nixosConfigurations.kodiak.config.system.build.diskoScript"
  target_host            = hcloud_server.kodiak.ipv4_address
  instance_id            = hcloud_server.kodiak.id
  install_ssh_key        = file("/tmp/grizzly-ssh-key")
  deployment_ssh_key     = file("/tmp/grizzly-ssh-key")
}
