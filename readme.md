# `grizzly`

```sh
sudo nixos-generate-config --show-hardware-config > hosts/grizzly/hardware-configuration.nix
mkdir -p ~/.config/sops/age
nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i /tmp/grizzly-ssh-key > ~/.config/sops/age/keys.txt"
sudo nixos-rebuild switch --flake .#grizzly
```

# `polar`

```sh
curl --proto '=https' --tlsv1.2 -L https://nixos.org/nix/install | sh
nix run --extra-experimental-features 'nix-command flakes' home-manager/master -- switch --flake .#polar
home-manager switch --flake .#polar
```

# `kodiak`

import private ssh key in `/tmp/kodiak-ssh-key`

```sh
sops exec-env secrets/secrets.yaml 'terraform apply'
```

## join the tailnet

Headscale is available at `https://vpn.rcastellotti.dev`. MagicDNS is enabled
with the `t.rcastellotti.dev` base domain, so a machine named `grizzly` is
reachable inside the tailnet as `grizzly.t.rcastellotti.dev` and, through the
injected search domain, as `grizzly`.

Create a Headscale user once on `kodiak`:

```sh
sudo headscale users create rc
```

List users to find the numeric ID assigned to `rc`, then create a short-lived,
single-use pre-authentication key using that ID:

```sh
sudo headscale users list
sudo headscale preauthkeys create --user USER_ID --expiration 1h
```

Tailscale is installed declaratively on `kodiak`, `grizzly`, and `polar`.
Deploy the relevant configuration (or install Tailscale on another client),
then join using the generated key:

```sh
sudo tailscale up \
  --login-server https://vpn.rcastellotti.dev \
  --auth-key HEADSCALE_PREAUTH_KEY
```

Confirm the node from the server and test MagicDNS from any joined client:

```sh
sudo headscale nodes list
tailscale ping CLIENT_HOSTNAME
```

### add ssh-key (run on machine with key in secrets/secrets.yaml)

1. generate an ssh key with bitwarden
2. temp copy the private key to ~/temp-new-key
3. `nix-shell -p ssh-to-age --run 'ssh-to-age -private-key -i ~/temp-new-key > ~/.config/sops/age/keys.txt'`
4. temp copy the public key to ~/temp-new-key.pub
5. `nix shell nixpkgs#ssh-to-age -c ssh-to-age < ~/temp-new-key.pub` (outputs pub age key)
6. `sops --add-age "$POLAR_AGE_RECIPIENT" --rotate --in-place secrets/secrets.yaml` (use key from above)
