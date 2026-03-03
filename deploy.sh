#!/usr/bin/env bash

temp=$(mktemp -d)

cleanup() {
  rm -rf "$temp"
}
trap cleanup EXIT

install -d -m755 "$temp/etc/ssh"

# Decrypt your private key from the password store and copy it to the temporary directory
cat /tmp/rc-ssh-key > "$temp/etc/ssh/ssh_host_ed25519_key"

chmod 600 "$temp/etc/ssh/ssh_host_ed25519_key"

nix run github:nix-community/nixos-anywhere -- --flake .#rcastellotti-dev --target-host root@89.167.105.83 --build-on-remote -i /tmp/rc-ssh-key --extra-files "$temp"
