#!/usr/bin/env bash

temp=$(mktemp -d)

cleanup() {
  rm -rf "$temp"
}
trap cleanup EXIT

install -d -m755 "$temp/etc/ssh"

bw get item $(bw list items --search "rc-ssh-key" | jq -r '.[].id') | jq -r '.sshKey.privateKey' > "$temp/etc/ssh/ssh_host_ed25519_key"

chmod 600 "$temp/etc/ssh/ssh_host_ed25519_key"

nix run github:nix-community/nixos-anywhere -- --flake .#rcastellotti-dev --target-host root@89.167.105.83 --build-on-remote -i /tmp/rc-ssh-key --extra-files "$temp"
