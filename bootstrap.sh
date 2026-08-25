#!/usr/bin/env bash
set -xeou pipefail
install -d -m755 ./etc/ssh
install -m600 /tmp/rcastellotti-dev-ssh-key ./etc/ssh/ssh_host_ed25519_key
