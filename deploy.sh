#!/usr/bin/env bash
# https://nix-community.github.io/nixos-anywhere/howtos/secrets.html
temp=$(mktemp -d)

cleanup() {
  rm -rf "$temp"
}
trap cleanup EXIT

install -d -m755 "$temp/etc/ssh"
SSH_KEY_ID=$(bw list items --search "rc-ssh-key" | jq -r '.[].id')
bw get item $SSH_KEY_ID | jq -r '.sshKey.privateKey' > "$temp/etc/ssh/ssh_host_ed25519_key"
chmod 600 "$temp/etc/ssh/ssh_host_ed25519_key"

nix run github:nix-community/nixos-anywhere -- \
  --flake .#rcastellotti-dev \
  --target-host root@89.167.105.83 \
  --build-on-remote \
  -i /tmp/rc-ssh-key \
  --extra-files "$temp"
