#!/usr/bin/env bash
# https://nix-community.github.io/nixos-anywhere/howtos/secrets.html
temp=$(mktemp -d)

cleanup() {
  rm -rf "$temp"
}
trap cleanup EXIT

install -d -m755 "$temp/etc/ssh"
bw get item $(bw list items --search "rc-ssh-key" | jq -r '.[].id') | jq -r '.sshKey.privateKey' > "$temp/etc/ssh/ssh_host_ed25519_key"
chmod 600 "$temp/etc/ssh/ssh_host_ed25519_key"

nixos-anywhere -- --flake .#rcast-dev --target-host root@rcast.dev --build-on remote -i /tmp/rc-ssh-key --extra-files "$temp"
