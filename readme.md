# grizzly

```sh
sudo nixos-generate-config --show-hardware-config > hosts/grizzly/hardware-configuration.nix
mkdir -p ~/.config/sops/age
nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i /tmp/rc-ssh-key > ~/.config/sops/age/keys.txt"
sudo nixos-rebuild switch --flake .#grizzly
```

# polar

```sh
curl -fsSL https://install.determinate.systems/nix | sh -s -- install
sudo nix run nix-darwin/master#darwin-rebuild -- switch --flake .#polar
mkdir -p ~/Library/Application Support/sops/age
nix-shell -p ssh-to-age --run "ssh-to-age -private-key -i /tmp/polar-ssh-key > ~/Library/Application Support/sops/age/keys.txt"
sudo darwin-rebuild switch --flake .#polar
```

# `rcastellotti-dev`

```sh
sops exec-env secrets/secrets.yaml 'terraform plan'
```

### add ssh-key (run on machine with key in secrets/secrets.yaml)

1. generate an ssh key with bitwarden
2. temp copy the private key to ~/temp-new-key
3. `nix-shell -p ssh-to-age --run 'ssh-to-age -private-key -i ~/temp-new-key > ~/.config/sops/age/keys.txt'`
4. temp copy the public key to ~/temp-new-key.pub
5. `nix shell nixpkgs#ssh-to-age -c ssh-to-age < ~/temp-new-key.pub` (outputs pub age key)
6. `sops --add-age "$POLAR_AGE_RECIPIENT" --rotate --in-place secrets/secrets.yaml` (use key from above)

## generate WG server key

1. `wg genkey | tee server.priv | wg pubkey > server.pub`
2. Edit the SOPS file with `sops secrets/secrets.yaml` (using `/tmp/rc-ssh-key` as the age identity).
3. create a client config to connect(see below)

## add a WG client:

1. generate key: `wg genkey | tee private.key | wg pubkey > public.key`
2. add it to the configuration block in `configuration.nix`
3. use the following config skeleton

```ini
[Interface]
PrivateKey = SERVER_PRIVATE_KEY
Address = 10.0.0.2/32
DNS = 1.1.1.1

[Peer]
PublicKey = CLIENT_PUBLIC_KEY
AllowedIPs = 10.0.0.2/24
Endpoint = vpn.rcastellotti.dev:51820
PersistentKeepalive = 25
```



  nix shell nixpkgs#ssh-to-age -c sh -c '
    ssh-to-age -private-key -i ~/polar-ssh-key
    ssh-to-age -private-key -i ~/rc-ssh-key
  ' > ~/.config/sops/age/keys.txt