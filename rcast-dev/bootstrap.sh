#!/usr/bin/env bash
# https://nix-community.github.io/nixos-anywhere/howtos/secrets.html
set -xeou pipefail

ROOT_HOST="${ROOT_HOST:?missing ROOT_HOST}"

temp=$(mktemp -d)

cleanup() {
  rm -rf "$temp"
}
trap cleanup EXIT

install -d -m755 "$temp/etc/ssh"
cp /tmp/rc-ssh-key "$temp/etc/ssh/ssh_host_ed25519_key"
chmod 600 "$temp/etc/ssh/ssh_host_ed25519_key"

nixos-anywhere -- \
    --flake .#rcast-dev \
    --target-host root@"$ROOT_HOST" \
    --build-on remote \
    -i /tmp/rc-ssh-key \
    --extra-files "$temp"
